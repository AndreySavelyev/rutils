module RuTils

  module Gilenson
    module StringFormatting
      # Форматирует строку с помощью Gilenson. Всп дополнительные опции передаются форматтеру.
      def gilensize(*args)
        args = {} unless args.is_a?(Hash)
        RuTils::Gilenson::Formatter.new(self, *args).to_html
      end
    end
  end
  
  # Это - прямой порт Тыпографицы от pixelapes.
  # Настройки можно регулировать через методы, т.е.
  #
  #   typ = Typografica.new('Эти "так называемые" великие деятели')
  #   typ.html = false     => "false"
  #   typ.dash = true      => "true"
  #   typ.to_html => 'Эти &#171;так называемые&#187; великие деятели'
  class Gilenson::Typografica    
    attr_accessor :glyph
    def initialize(text, *args)
      @_text = text
      @skip_tags = true;
      @p_prefix = "<p class=typo>";
      @p_postfix = "</p>";
      @a_soft = true;
      @indent_a = "images/z.gif width=25 height=1 border=0 alt=\'\' align=top />" # <->
      @indent_b = "images/z.gif width=50 height=1 border=0 alt=\'\' align=top />" # <-->
      @fixed_size = 80  # максимальная ширина
      @ignore = /notypo/ # regex, который игнорируется. Этим надо воспользоваться для обработки pre и code

      @glueleft =  ['рис.', 'табл.', 'см.', 'им.', 'ул.', 'пер.', 'кв.', 'офис', 'оф.', 'г.']
      @glueright = ['руб.', 'коп.', 'у.е.', 'мин.']

      @settings = {
                    "inches"    => true,    # преобразовывать дюймы в &quot;
                    "laquo"     => true,    # кавычки-ёлочки
                    "farlaquo"  => false,   # кавычки-ёлочки для фара (знаки "больше-меньше")
                    "quotes"    => true,    # кавычки-английские лапки
                    "dash"      => true,    # короткое тире (150)
                    "emdash"    => true,    # длинное тире двумя минусами (151)
                    "(c)"       => true,
                    "(r)"       => true,
                    "(tm)"      => true,
                    "(p)"       => true,
                    "+-"        => true,    # спецсимволы, какие - понятно
                    "degrees"   => true,    # знак градуса
                    "<-->"      => true,    # отступы $Indent*
                    "dashglue"  => true, "wordglue" => true, # приклеивание предлогов и дефисов
                    "spacing"   => true,    # запятые и пробелы, перестановка
                    "phones"    => true,    # обработка телефонов
                    "fixed"     => false,   # подгон под фиксированную ширину
                    "html"      => false,   # запрет тагов html
                    "de_nobr"   => true,    # при true все <nobr/> заменяются на <span class="nobr"/>
                   }
      # irrelevant - indentation with images
      @indent_a = "<!--indent-->"
      @indent_b = "<!--indent-->"
      
      @mark_tag = "\xF0\xF0\xF0\xF0" # Подстановочные маркеры тегов
      @mark_ignored = "\201" # Подстановочные маркеры неизменяемых групп
      
      # XHTML... Даёшь!
      @glyph = {
                    :quot       => "&#34;",     # quotation mark
                    :amp        => "&#38;",     # ampersand
                    :apos       => "&#39;",     # apos
                    :gt         => "&#62;",     # greater-than sign
                    :lt         => "&#60;",     # less-than sign
                    :nbsp       => "&#160;",    # non-breaking space
                    :sect       => "&#167;",    # section sign
                    :copy       => "&#169;",    # copyright sign
                    :laquo      => "&#171;",    # left-pointing double angle quotation mark = left pointing guillemet
                    :reg        => "&#174;",    # registered sign = registered trade mark sign
                    :deg        => "&#176;",    # degree sign
                    :plusmn     => "&#177;",    # plus-minus sign = plus-or-minus sign
                    :middot     => "&#183;",    # middle dot = Georgian comma = Greek middle dot
                    :raquo      => "&#187;",    # right-pointing double angle quotation mark = right pointing guillemet
                    :ndash      => "&#8211;",   # en dash
                    :mdash      => "&#8212;",   # em dash
                    :lsquo      => "&#8216;",   # left single quotation mark
                    :rsquo      => "&#8217;",   # right single quotation mark
                    :ldquo      => "&#8220;",   # left double quotation mark
                    :rdquo      => "&#8221;",   # right double quotation mark
                    :bdquo      => "&#8222;",   # double low-9 quotation mark
                    :bull       => "&#8226;",   # bullet = black small circle
                    :hellip     => "&#8230;",   # horizontal ellipsis = three dot leader
                    :trade      => "&#8482;",   # trade mark sign
                    :minus      => "&#8722;",   # minus sign
               }
      
      # Кто придумал &#147;? Не учите людей плохому...
      # Привет А.Лебедеву http://www.artlebedev.ru/kovodstvo/62/
      @glyph_ugly = {
                    '132'       => @glyph[:bdquo],
                    '133'       => @glyph[:hellip],
                    '146'       => @glyph[:apos],
                    '147'       => @glyph[:ldquo],
                    '148'       => @glyph[:rdquo],
                    '149'       => @glyph[:bull],
                    '150'       => @glyph[:ndash],
                    '151'       => @glyph[:mdash],
                    '153'       => @glyph[:trade],
               }
      
      @phonemasks = [[  /([0-9]{4})\-([0-9]{2})\-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/,
                        /([0-9]{4})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{3})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{2})\-([0-9]{2})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{3})\-([0-9]{2})/,
                        /(\([0-9\+\-]+\)) ?([0-9]{2})\-([0-9]{3})/,
                        /([0-9]{3})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{2})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{1})\-([0-9]{2})\-([0-9]{2})/,
                        /([0-9]{2})\-([0-9]{3})/,
                        /([0-9]+)\-([0-9]+)/,
                      ],[    
                       '<nobr>\1' + @glyph[:ndash] +'\2' + @glyph[:ndash] + '\3' + @glyph[:nbsp]  + '\4:\5:\6</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:nbsp]  +'\2' + @glyph[:ndash] + '\3' + @glyph[:ndash] + '\4</nobr>',
                       '<nobr>\1' + @glyph[:nbsp]  +'\2' + @glyph[:ndash] + '\3' + @glyph[:ndash] + '\4</nobr>',
                       '<nobr>\1' + @glyph[:nbsp]  +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:nbsp]  +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2' + @glyph[:ndash] + '\3</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2</nobr>',
                       '<nobr>\1' + @glyph[:ndash] +'\2</nobr>'
                    ]]
    end


    # Proxy unknown method calls as setting switches. Methods with = will set settings, methods without - fetch them
    def method_missing(meth, *args) #:nodoc:
      setting = meth.to_s.gsub(/=$/, '')
      super(meth, *args) unless @settings.has_key?(setting) #this will pop the exception if we have no such setting

      return @settings[meth.to_s] if setting == meth.to_s  
      return (@settings[meth.to_s] = args[0])
    end


    def to_html(no_paragraph = false)

      text = @_text
      
      # Замена &entity_name; на входе ('&nbsp;' => '&#160;' и т.д.)
      @glyph.each {|key,value| text.gsub!(/&#{key};/, value)}
      
      # Никогда (вы слышите?!) не пущать лабуду &#not_correct_number;
      @glyph_ugly.each {|key,value| text.gsub!(/&##{key};/, value)}


      # -2. игнорируем ещё регексп
      ignored = []

  
      text.scan(@ignore) do |result|
        ignored << result
      end

      text.gsub!(@ignore, @mark_ignored)  # маркер игнора

      # -1. запрет тагов html
      text.gsub!(/&/, self.glyph[:amp]) if @settings["html"]


       # 0. Вырезаем таги
      #  проблема на самом деле в том, на что похожи таги.
      #   вариант 1, простой (закрывающий таг) </abcz>
      #   вариант 2, простой (просто таг)      <abcz>
      #   вариант 3, посложней                 <abcz href="abcz">
      #   вариант 4, простой (просто таг)      <abcz />
      #   вариант 5, вакка                     \xA2\xA2...== нафиг нафиг
      #   самый сложный вариант - это когда в параметре тага встречается вдруг символ ">"
      #   вот он: <abcz href="abcz>">
      #  как работает вырезание? введём спецсимвол. Да, да, спецсимвол.
      #    нам он ещё вопьётся =)
      #  заменим все таги на спец.символ, запоминая одновременно их в массив. 
      #  и будем верить, что спец.символы в дикой природе не встречаются.

      tags = []
      if @skip_tags
      #     re =  /<\/?[a-z0-9]+("+ # имя тага
      #                              "\s+("+ # повторяющая конструкция: хотя бы один разделитель и тельце
      #                                     "[a-z]+("+ # атрибут из букв, за которым может стоять знак равенства и потом
      #                                              "=((\'[^\']*\')|(\"[^\"]*\")|([0-9@\-_a-z:\/?&=\.]+))"+ # 
      #                                           ")?"+
      #                                  ")?"+
      #                            ")*\/?>|\xA2\xA2[^\n]*?==/i;

      #     re =  /<\/?[a-z0-9]+(\s+([a-z]+(=((\'[^\']*\')|(\"[^\"]*\")|([0-9@\-_a-z:\/?&=\.]+)))?)?)*\/?>|\xA2\xA2[^\n]*?==/ui

        re =  /(<\/?[a-z0-9]+(\s+([a-z]+(=((\'[^\']*\')|(\"[^\"]*\")|([0-9@\-_a-z:\/?&=\.]+)))?)?)*\/?>)/ui

# по-хорошему атрибуты тоже нужно типографить. Или не нужно? бугага...

        tags = text.scan(re).map{|tag| tag[0] }
#            match = "&lt;" + match if @settings["html"]
        text.gsub!(re, @mark_tag) #маркер тега, мы используем Invalid UTF-sequence для него
    
#    puts "matched #{tags.size} tags"
      end

      # 1. Запятые и пробелы
      if @settings["spacing"]
        text.gsub!( /(\s*)([,]*)/sui, '\2\1');
        text.gsub!( /(\s*)([\.?!]*)(\s*[ЁА-ЯA-Z])/su, '\2\1\3');
      end

      # 2. Разбиение на строки длиной не более ХХ символов
      # --- для ваки не портировано ---
      # --- для ваки не портировано ---

      # 3. Спецсимволы
      # 0. дюймы с цифрами
      text.gsub!(/\s([0-9]{1,2}([\.,][0-9]{1,2})?)\"/ui, ' \1'+self.glyph[:quot]) if @settings["inches"]

      # 1. лапки
      if @settings["quotes"]
        text.gsub!( /\"\"/ui, self.glyph[:quot]*2)
        text.gsub!( /\"\.\"/ui, self.glyph[:quot]+"."+self.glyph[:quot])
        _text = '""';
        while _text != text do  
          _text = text
          text.gsub!( /(^|\s|\201|\xF0\xF0\xF0\xF0|>)\"([0-9A-Za-z\'\!\s\.\?\,\-\&\;\:\_\xF0\xF0\xF0\xF0\201]+(\"|#{self.glyph[:rdquo]}))/ui, '\1'+self.glyph[:ldquo]+'\2')
          #this doesnt work in-place. somehow.
          text = text.gsub( /(#{self.glyph[:ldquo]}([A-Za-z0-9\'\!\s\.\?\,\-\&\;\:\xF0\xF0\xF0\xF0\201\_]*).*[A-Za-z0-9][\xF0\xF0\xF0\xF0\201\?\.\!\,]*)\"/ui, '\1'+self.glyph[:rdquo])
        end
      end

      # 2. ёлочки
      if @settings["laquo"]
        text.gsub!( /\"\"/ui, self.glyph[:quot]*2);
        text.gsub!( /(^|\s|\201|\xF0\xF0\xF0\xF0|>|\()\"((\201|\xF0\xF0\xF0\xF0)*[~0-9ёЁA-Za-zА-Яа-я\-:\/\.])/ui, '\1'+self.glyph[:laquo]+'\2');
        # nb: wacko only regexp follows:
        text.gsub!( /(^|\s|\201|\xF0\xF0\xF0\xF0|>|\()\"((\201|\xF0\xF0\xF0\xF0|\/#{self.glyph[:nbsp]}|\/|\!)*[~0-9ёЁA-Za-zА-Яа-я\-:\/\.])/ui, '\1'+self.glyph[:laquo]+'\2')
        _text = '""';
        while (_text != text) do
          _text = text;
          text.gsub!( /(#{self.glyph[:laquo]}([^\"]*)[ёЁA-Za-zА-Яа-я0-9\.\-:\/](\201|\xF0\xF0\xF0\xF0)*)\"/sui, '\1'+self.glyph[:raquo])
          # nb: wacko only regexps follows:
          text.gsub!( /(#{self.glyph[:laquo]}([^\"]*)[ёЁA-Za-zА-Яа-я0-9\.\-:\/](\201|\xF0\xF0\xF0\xF0)*\?(\201|\xF0\xF0\xF0\xF0)*)\"/sui, '\1'+self.glyph[:raquo])
          text.gsub!( /(#{self.glyph[:raquo]}([^\"]*)[ёЁA-Za-zА-Яа-я0-9\.\-:\/](\201|\xF0\xF0\xF0\xF0|\/|\!)*)\"/sui, '\1'+self.glyph[:raquo])
        end
      end


        # 2b. одновременно ёлочки и лапки
        if (@settings["quotes"] && (@settings["laquo"] or @settings["farlaquo"]))
          text.gsub!(/(#{self.glyph[:ldquo]}(([A-Za-z0-9'!\.?,\-&;:]|\s|\xF0\xF0\xF0\xF0|\201)*)#{self.glyph[:laquo]}(.*)#{self.glyph[:raquo]})#{self.glyph[:raquo]}/ui,'\1'+self.glyph[:rdquo]);
        end


        # 3. тире
        if @settings["dash"]
          text.gsub!( /(\s|;)\-(\s)/ui, '\1'+self.glyph[:ndash]+'\2')
        end


        # 3a. тире длинное
        if @settings["emdash"]
          text.gsub!( /(\s|;)\-\-(\s)/ui, '\1'+self.glyph[:mdash]+'\2')
          # 4. (с)
          text.gsub!(/\([сСcC]\)((?=\w)|(?=\s[0-9]+))/u, self.glyph[:copy]) if @settings["(c)"]
          # 4a. (r)
          text.gsub!( /\(r\)/ui, '<sup>'+self.glyph[:reg]+'</sup>') if @settings["(r)"]

          # 4b. (tm)
          text.gsub!( /\(tm\)|\(тм\)/ui, self.glyph[:trade]) if @settings["(tm)"]
          # 4c. (p)   
          text.gsub!( /\(p\)/ui, self.glyph[:sect]) if @settings["(p)"]
        end


        # 5. +/-
        text.gsub!(/[^+]\+\-/ui, self.glyph[:plusmn]) if @settings["+-"]


        # 5a. 12^C
        if @settings["degrees"]
          text.gsub!( /-([0-9])+\^([FCС])/, self.glyph[:ndash]+'\1'+self.glyph[:deg]+'\2') #deg
          text.gsub!( /\+([0-9])+\^([FCС])/, '+\1'+self.glyph[:deg]+'\2')
          text.gsub!( /\^([FCС])/, self.glyph[:deg]+'\1')
        end


         # 6. телефоны
        if @settings["phones"]
          @phonemasks[0].each_with_index do |v, i|
            text.gsub!(v, @phonemasks[1][i])
          end
        end


      # 7. Короткие слова и &nbsp;
      if @settings["wordglue"]

        text = " " + text + " ";
        _text = " " + text + " ";
        until _text == text
           _text = text
           text.gsub!( /(\s+)([a-zа-яА-Я]{1,2})(\s+)([^\\s$])/ui, '\1\2'+self.glyph[:nbsp]+'\4')
           text.gsub!( /(\s+)([a-zа-яА-Я]{3})(\s+)([^\\s$])/ui,   '\1\2'+self.glyph[:nbsp]+'\4')
        end

        for i in @glueleft
           text.gsub!( /(\s)(#{i})(\s+)/sui, '\1\2'+self.glyph[:nbsp])
        end

        for i in @glueright 
           text.gsub!( /(\s)(#{i})(\s+)/sui, self.glyph[:nbsp]+'\2\3')
        end
      end



      # 8. Склейка ласт. Тьфу! дефисов.
      text.gsub!( /([a-zа-яА-Я0-9]+(\-[a-zа-яА-Я0-9]+)+)/ui, '<nobr>\1</nobr>') if @settings["dashglue"]


      # 9. Макросы



      # 10. Переводы строк
      # --- для ваки не портировано ---
      # --- для ваки не портировано ---


      # БЕСКОНЕЧНОСТЬ. Вставляем таги обратно.
    #  if (@skip_tags)
#    text = text.split("\xF0\xF0\xF0\xF0").join
#        

    tags.each do |tag|
      text.sub!(@mark_tag, tag)
    end
  
#        i = 0
#        text.gsub!(@mark_tag) {
#          i + 1
#          tags[i-1]
#        }

#      text = text.split("\xF0\xF0\xF0\xF0")
#puts "reinserted #{i} tags"
#
    #  end
      

#ext.gsub!("a", '')
#      raise "Text still has tag markers!" if text.include?("a")

      # БЕСКОНЕЧНОСТЬ-2. вставляем ещё сигнорированный регексп
      #
#      if @ignore
#        ignored.each { | tag | text.sub!(@mark_ignored, tag) }
#      end

#      raise "Text still has ignored markers!" if text.include?("\201")

      # БОНУС: прокручивание ссылок через A(...)
      # --- для ваки не портировано ---
      # --- для ваки не портировано ---
      
      # фуф, закончили.
      if @settings["de_nobr"]
        text.gsub!(/<nobr>/, '<span class="nobr">')
        text.gsub!(/<\/nobr>/, '</span>')
      end

      text.gsub(/(\s)+$/, "").gsub(/^(\s)+/, "")

    end

    private

  end

end #end RuTils

# Вгружаем этот форматтер если уже не загружен наш новый
unless defined?(RuTils::Gilenson::Formatter)
  class RuTils::Gilenson::Formatter < RuTils::Gilenson::Typografica
  end
end

class Object::String
  include RuTils::Gilenson::StringFormatting
end
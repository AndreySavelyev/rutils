module RuTils
	module Pluralization
		#
		# "Сумма прописью":
		#	 преобразование числа из цифрого вида в символьное
		#===============================================
		# Исходные данные:
		# amount - число от 0 до 2147483647 (2^31-1)
		# Eсли нужно оперировать с числами > 2 147 483 647,
		# замените описание переменных amount и tmp_val
		# на "AS DOUBLE"
		# Далее нужно задать информацию о единице изменения:
		# gender	 = 1 - мужской, = 2 - женский, = 3 - средний
		# Название единицы изменения:
		# one_item - именительный падеж единственного числа (= 1)
		# two_items - родительный падеж единственного числа (= 2-4)
		# five_items - родительный падеж множественного числа ( = 5-10)
		#
		# gender должен быть задан обязательно, 
		# название единицы может быть не задано = ""
		# -------------------------------
		# Результат: into - запись прописью
		#================================
		def self.sum_string(into, amount, gender, one_item='', two_items='', five_items='')
				tmp_val ||= 0

				return "ноль " + five_items if amount == 0

				tmp_val = amount

				# единицы
				into, tmp_val = sum_string_fn(into, tmp_val, gender, one_item, two_items, five_items)

				return into if tmp_val == 0

				# тысячи
				into, tmp_val = sum_string_fn(into, tmp_val, 2, "тысяча", "тысячи", "тысяч") 

				return into if tmp_val == 0

				# миллионы
				into, tmp_val = sum_string_fn(into, tmp_val, 1, "миллион", "миллиона", "миллионов")

				return into if tmp_val == 0

				# миллиардов
				into, tmp_val = sum_string_fn(into, tmp_val, 1, "миллиард", "миллиарда", "миллиардов")
				return into
		end
		
		def self.sum_string_fn(into, tmp_val, gender, one_item='', two_items='', five_items='')
		 #
		 # Формирование строки для трехзначного числа:
		 # (последний из трех знаков tmp_val)
		 # Eсли нужно оперировать с числами > 2 147 483 647,
		 # замените в описании на tmp_val AS DOUBLE 
		 #=========================================
			rest, rest1, end_word, ones, tens, hundreds = [nil]*6
			#

			rest = tmp_val % 1000
			tmp_val = tmp_val / 1000
			if rest == 0 
				# последние три знака нулевые 
				into = five_items + " " if into == ""
				return [into, tmp_val]
			end
			#
			# начинаем подсчет с Rest
			end_word = five_items
			# сотни
			case rest / 100
				when 0 then hundreds = ""
				when 1 then hundreds = "сто "
				when 2 then hundreds = "двести "
				when 3 then hundreds = "триста "
				when 4 then hundreds = "четыреста "
				when 5 then hundreds = "пятьсот "
				when 6 then hundreds = "шестьсот "
				when 7 then hundreds = "семьсот "
				when 8 then hundreds = "восемьсот "
				when 9 then hundreds = "девятьсот "
			end

			# десятки
			rest = rest % 100
			rest1 = rest / 10
			ones = ""
			case rest1
				when 0 then tens = ""
				when 1 # особый случай
					case rest
						when 10 then tens = "десять "
						when 11 then tens = "одиннадцать "
						when 12 then tens = "двенадцать "
						when 13 then tens = "тринадцать "
						when 14 then tens = "четырнадцать "
						when 15 then tens = "пятнадцать "
						when 16 then tens = "шестнадцать "
						when 17 then tens = "семнадцать "
						when 18 then tens = "восемнадцать "
						when 19 then tens = "девятнадцать "
					end
				when 2: tens = "двадцать "
				when 3: tens = "тридцать "
				when 4: tens = "сорок "
				when 5: tens = "пятьдесят "
				when 6: tens = "шестьдесят "
				when 7: tens = "семьдесят "
				when 8: tens = "восемьдесят "
				when 9: tens = "девяносто "
			end
			#
			if rest1 < 1 or rest1 > 1 # единицы
				case rest % 10
					when 1
						case gender
							when 1
								ones = "один "
							when 2
								ones = "одна "
							when 3
								ones = "одно "
						end
						end_word = one_item
					when 2
						if gender == 2
							ones = "две "
						else
							ones = "два " 
						end			 
						end_word = two_items
					when 3
						ones = "три " if end_word = two_items
					when 4
						ones = "четыре " if end_word = two_items
					when 5
						ones = "пять "
					when 6
						ones = "шесть "
					when 7
						ones = "семь "
					when 8
						ones = "восемь "
					when 9
						ones = "девять "
				end
			end
			
			# сборка строки
			return [(hundreds + tens + ones + end_word + " " + into).strip, tmp_val] 
		end

		def self.items(amount, gender, one_item, two_items, three_items)
			RuTils::Pluralization::sum_string("", amount, gender, one_item, two_items, three_items)
		end
		
		# Реализует вывод прописью любого объекта, реализующего Float
		module FloatFormatting
			
			# Выдает сумму прописью с учетом дробной доли. Дробная доля округляется до миллионной, или (если
			# дробная доля оканчивается на нули) до ближайшей доли ( 500 тысячных округляется до 5 десятых)
			def propisju
				raise "Cannot write something propisju whith is NaN" if self.nan?
		
				st = RuTils::Pluralization::sum_string("", self.to_i, 2, "целая", "целых", "целых")
				it = []
	
				rmdr = self.to_s.match(/\.(\d+)/)[1]
		
				signs = rmdr.to_s.size- 1
				
				it << ["десятая", "десятых", "десятых"]
				it << ["сотая", "сотых", "сотых"]
				it << ["тысячная", "тысячных", "тысячных"]
				it << ["десятитысячная", "десятитысячных", "десятитысячных"]
				it << ["стотысячная", "стотысячных", "стотысячных"]
				it << ["миллионная", "милллионных", "миллионных"]
		 # 	it << ["десятимиллионная", "десятимилллионных", "десятимиллионных"]
		 # 	it << ["стомиллионная", "стомилллионных", "стомиллионных"]
		 # 	it << ["миллиардная", "миллиардных", "миллиардных"]
		 # 	it << ["десятимиллиардная", "десятимиллиардных", "десятимиллиардных"]
		 # 	it << ["стомиллиардная", "стомиллиардных", "стомиллиардных"]
		 # 	it << ["триллионная", "триллионных", "триллионных"]

				while it[signs].nil?
					rmdr = (rmdr/10).round
					signs = rmdr.to_s.size- 1
				end
								
				suf1, suf2, suf3 = it[signs][0], it[signs][1], it[signs][2]		
				st + " " + RuTils::Pluralization::sum_string("", rmdr.to_i, 2, suf1, suf2, suf3)
			end
		end
		
		# Реализует вывод прописью любого объекта, реализующего Numeric
		module NumericFormatting
			# Выбирает корректный вариант числительного в зависимости от рода и числа и оформляет сумму прописью
			# 234.propisju => "двести сорок три"
			def propisju
				RuTils::Pluralization::sum_string("", self, 1, "")
			end
			
			# Выбирает корректный вариант числительного в зависимости от рода и числа
			def items(gender, one_item, two_items, three_items)
				RuTils::Pluralization::items(self, gender, one_item, two_items, three_items)
			end	
		end
		
		# Реализует вывод множественного числа в зависимости от числительного
		module StringFormatting
			
			# Конвертирует строку в именительном падеже единственного числа в нужный падеж в зависимости от количества
			# Названа ru_pluralize чтобы не конфликтовать с pluralize, обеспечиваемым ActiveSupport в Rails.
			# Кто реализует?
			def ru_pluralize(amount)
				self
			end
		end
	end
end

class Numeric
	include RuTils::Pluralization::NumericFormatting
end

class String
	include RuTils::Pluralization::StringFormatting
end

class Float
	include RuTils::Pluralization::FloatFormatting
end


class Fixnum
	include RuTils::Pluralization::StringFormatting
end

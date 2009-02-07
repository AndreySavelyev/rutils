# -*- encoding: utf-8 -*- 
$KCODE = 'u'
$:.reject! { |e| e.include? 'TextMate' }

require 'lib/version'

begin
  require 'rubygems'
  require 'hoe'
  
  # Disable spurious warnings when running tests, ActiveMagic cannot stand -w
  Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib test).join(File::PATH_SEPARATOR)}" + 
    (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
  
  # Hoe minus dependency pollution plus unidocs plus rdoc fix. Kommunizm, perestroika.
  Class.new(Hoe) do
    DOCOPTS = %w(--webcvs=http://github.com/julik/rutils/tree/master/%s --charset=utf-8 --promiscuous)
    Rake::RDocTask.class_eval do
      alias_method :_odefine, :define
      def define; @options.unshift(*DOCOPTS); _odefine; end
    end
    
    def define_tasks
      extra_deps.reject! {|e| e[0] == 'hoe' }
      super
    end
  end.new('rutils', RuTils::VERSION) do |p|
    p.name = "rutils"
    p.author = ["Julian 'Julik' Tarkhanov", "Danil Ivanov", "Yaroslav Markin"]
    p.email = ['me@julik.nl', 'yaroslav@markin.net']
    p.description = 'Simple processing of russian strings'
    p.summary     = 'Simple processing of russian strings'
    p.remote_rdoc_dir = ''
    p.need_zip = true # ненвижу
  end

  require 'load_multi_rails_rake_tasks'
  
rescue LoadError
  $stderr.puts "Meta-operations on this package require Hoe and multi_rails"
  task :default => [ :test ]
  
  require 'rake/testtask'
  desc "Run all tests (requires BlueCloth, RedCloth and Rails for integration tests)"
  Rake::TestTask.new("test") do |t|
    t.libs << "test"
    t.pattern = 'test/t_*.rb'
    t.verbose = true
  end
end
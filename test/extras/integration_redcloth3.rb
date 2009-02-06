# -*- encoding: utf-8 -*- 
require 'redcloth'

raise LoadError, "need RedCloth 3.x" unless RedCloth::VERSION =~ /^3/

# Интеграция с RedCloth - Textile.
# Нужно иметь в виду что Textile осуществляет свою обработку типографики, которую мы подменяем!
class Redcloth3IntegrationTest < Test::Unit::TestCase
  def test_integration_with_redcloth_3
    flunk("You must have RedCloth to test Textile integration") if $skip_redcloth
    flunk("This test is for RedCloth 3 and less but ran on #{RedCloth::VERSION}") if RedCloth::VERSION.to_s.to_i > 3
    
    RuTils::overrides = true
    assert RuTils.overrides_enabled?
    
    assert_equal "<p>И&#160;вот &#171;они пошли туда&#187;, и&#160;шли шли&#160;шли</p>", 
      RedCloth.new('И вот "они пошли туда", и шли шли шли').to_html
    
    RuTils::overrides = false      
    assert !RuTils::overrides_enabled?
    assert_equal '<p><strong>strong text</strong> and <em>emphasized text</em></p>',
      RedCloth.new("*strong text* and _emphasized text_").to_html, 
        "Spaces should be preserved without RuTils"
    
    RuTils::overrides = true      
    assert RuTils.overrides_enabled?
    assert_equal '<p><strong>strong text</strong> and <em>emphasized text</em></p>',
      RedCloth.new("*strong text* and _emphasized text_").to_html,
        "Spaces should be preserved"
    
    RuTils::overrides = false
    assert !RuTils.overrides_enabled?
    assert_equal "<p>И вот &#8220;они пошли туда&#8221;, и шли шли шли</p>", 
      RedCloth.new('И вот "они пошли туда", и шли шли шли').to_html
  
  end
end
require 'constants'

class ReadMeDocTest < Test::Unit::TestCase
 
  include Constants::Libraries

  def test_documentation
    # Element predefines all chemical elements
    c = Element::C
    assert_equal "Carbon", c.name
    assert_equal "C", c.symbol 
    assert_equal 6, c.atomic_number
    assert_equal 12.0, c.mass(12)
    assert_equal 13.0033548378, c.mass(13)

    assert c == Element['Carbon']
    assert c == Element['C']
    assert c == Element[6]
  end
  
end

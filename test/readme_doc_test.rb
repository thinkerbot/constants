require 'constants'

class ReadMeDocTest < Test::Unit::TestCase
 
  include Constants::Libraries

  # A library of amino acid residues.
  class Residue
    attr_reader :letter, :abbr, :name

    def initialize(letter, abbr, name)
      @letter = letter
      @abbr = abbr
      @name = name
    end

    A = Residue.new('A', "Ala", "Alanine")
    C = Residue.new('C', "Cys", "Cysteine")
    D = Residue.new('D', "Asp", "Aspartic Acid")
    # ... normally you'd add the rest here ...

    include Constants::Library

    # add an index by an attribute or method
    library.index_by_attribute :letter

    # add an index where keys are calculated by a block
    library.index_by 'upcase abbr' do |residue|
      residue.abbr.upcase
    end
    
    # add a collection (same basic idea, but using an array)
    library.collect_attribute 'name'
  end
  
  def test_documentation
    # Element predefines all chemical elements
    c = Element::C
    assert_equal "Carbon", c.name
    assert_equal "C", c.symbol 
    assert_equal 6, c.atomic_number
    assert_equal 12.0, c.mass
    assert_equal 13.0033548378, c.mass(13)

    assert c == Element['Carbon']
    assert c == Element['C']
    assert c == Element[6]
  
    ###
    assert_equal Residue::D, Residue['D']
    assert_equal Residue::A, Residue['ALA']

    assert_equal({'ALA' => Residue::A, 'CYS' => Residue::C, 'ASP' => Residue::D}, Residue.index('upcase abbr'))
    const_ordered_assert_equal(["Alanine", "Cysteine", "Aspartic Acid"], Residue.collection('name'))
  end
  
end

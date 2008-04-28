require File.join(File.dirname(__FILE__), '../../constants_test_helper.rb') 
require 'constants/library/element'

class ElementTest < Test::Unit::TestCase
  include Constants::Library

  def test_initialize
    c = Element::C
    
    assert_equal "C", c.symbol
    assert_equal "Carbon", c.name
    assert_equal 6, c.atomic_number
    assert_equal [12, 13], c.isotopes
    assert_equal [[12.0, 0], [13.0033548378, 0.000000001]], c.masses.collect {|m| m.to_a}
    assert_equal [[98.93, 0.08], [1.07, 0.08]], c.abundances.collect {|m| m.to_a}
    assert_equal 0, c.index_max_abundance
    assert_equal 2, c.index
    assert_equal c, Element::INDEX[2]
  end
  
  def test_class_lookup
    c = Element::C
    
    assert_equal c, Element['C']
    assert_nil Element['Q']
  end

  def test_has_isotope?
    assert Element::C.has_isotope?(12)
    assert Element::C.has_isotope?(13)
    assert !Element::C.has_isotope?(8)
  end

  def test_index_isotope
    assert_equal 0, Element::C.index_isotope(12)
    assert_equal 1, Element::C.index_isotope(13)
    assert_equal nil, Element::C.index_isotope(8)
  end
  
  def test_mass
    assert_equal 12, Element::C.mass
    assert_equal 12, Element::C.mass(12)
    assert_equal 13.0033548378, Element::C.mass(13)
    assert_equal nil, Element::C.mass(8)
  end
  
  def test_abundance
    assert_equal 98.93, Element::C.abundance
    assert_equal 98.93, Element::C.abundance(12)
    assert_equal 1.07, Element::C.abundance(13)
    assert_equal nil, Element::C.abundance(8)
  end
  
  def test_by_name
    assert_equal Element::C, Element["Carbon"]
    assert_nil Element["madeupium"]
  end
    
  def test_by_number
    assert_equal Element::C, Element[6]
    assert_nil Element[102]
  end
  
  # vs the Proteome Commons Atom Reference, 2008-01-11
  # http://www.proteomecommons.org/archive/1129086318745/docs/atom-reference.html
  #
  # The website states 'These values are taken from the NIST's list, http://physics.nist.gov'
  def test_mass_values_vs_proteome_commons
    str = %Q{
H	1.0078250321	0.999885
H2	2.014101778	1.15E-4
O	15.9949146221	0.9975700000000001
O17	16.9991315	3.7999999999999997E-4
O18	17.9991604	0.0020499999999999997
N14	14.0030740052	0.9963200000000001
N15	15.0001088984	0.00368
C12	12.0	0.9893000000000001
C13	13.0033548378	0.010700000000000001
P31	30.97376151	1.0
S32	31.97207069	0.9493
S33	32.9714585	0.0076
S34	33.96786683	0.0429
S36	35.96708088	2.0E-4}

    atoms = str.split(/\n/)
    atoms.each do |atom_str|
      next if atom_str.empty?
      
      name, mass, abundance = atom_str.split(/\s/)
      name =~ /(\w)(\d*)/
      symbol = $1
      isotope = $2.empty? ? nil : $2.to_i
      mass = mass.to_f
      abundance = abundance.to_f * 100
      
      element = Element[symbol]
      assert_not_nil element, atom_str
      assert element.has_isotope?(isotope), atom_str unless isotope == nil
      
      assert_in_delta mass, element.mass(isotope), delta_mass, atom_str 
      assert_in_delta abundance, element.abundance(isotope), delta_abundance, atom_str 
    end
  end
  
  # vs the Unimod Symbols and Mass Values, 2008-01-11
  # http://www.unimod.org/masses.html
  #
  # The website states 'All mass values in Unimod are calculated 
  # from the IUPAC atomic weights and isotopic abundances 
  # tabulated by WebElements'
  #
  def test_mass_values_vs_unimod
    str = %Q{
H	Hydrogen	1.007825035	1.00794
2H	Deuterium	2.014101779	2.014101779
Li	Lithium	7.016003	6.941
C	Carbon	12	12.0107
13C	Carbon13	13.00335483	13.00335483
N	Nitrogen	14.003074	14.0067
15N	Nitrogen15	15.00010897	15.00010897
O	Oxygen	15.99491463	15.9994
18O	Oxygen18	17.9991603	17.9991603
F	Fluorine	18.99840322	18.9984032
Na	Sodium	22.9897677	22.98977
P	Phosphorous	30.973762	30.973761
S	Sulfur	31.9720707	32.065
Cl	Chlorine	34.96885272	35.453
K	Potassium	38.9637074	39.0983
Ca	Calcium	39.9625906	40.078
Fe	Iron	55.9349393	55.845
Ni	Nickel	57.9353462	58.6934
Cu	Copper	62.9295989	63.546
Zn	Zinc	63.9291448	65.409
Br	Bromine	78.9183361	79.904
Se	Selenium	79.9165196	78.96
Mo	Molybdenum	97.9054073	95.94
Ag	Silver	106.905092	107.8682
I	Iodine	126.904473	126.90447
Au	Gold	196.966543	196.96655
Hg	Mercury	201.970617	200.59}

    atoms = str.split(/\n/)
    atoms.each do |atom_str|
      next if atom_str.empty?
      
      symbol, name, monoisotopic, average = atom_str.split(/\s/)
      symbol =~ /(\d*)(\w+)/
      isotope = $1.empty? ? nil : $1.to_i
      symbol = $2
      monoisotopic = monoisotopic.to_f
      average = average.to_f
      
      element = Element[symbol]
      assert_not_nil element, atom_str
      assert element.has_isotope?(isotope), atom_str unless isotope == nil

      assert_in_delta monoisotopic, element.mass(isotope), delta_mass, atom_str 
      # TODO -- check average mass
    end
  end

  # vs the VG Analytical Organic Mass Spectrometry reference, reference date unknown (prior to 2005)
  # the data from the data sheet was copied manually to doc/VG Analytical DataSheet.txt
  def test_mass_values_vs_vg_analytical
    str = %Q{
H 1.0078250 1.00794
C 12 12.011
N 14.0030740 14.0067
O 15.9949146 15.9994
S 31.9720718 32.06}

    atoms = str.split(/\n/)
    atoms.each do |atom_str|
      next if atom_str.empty?
      
      symbol, monoisotopic, average = atom_str.split(/\s/)
      monoisotopic = monoisotopic.to_f
      average = average.to_f
      
      element = Element[symbol]
      assert_not_nil element, atom_str
      assert_in_delta monoisotopic, element.mass, delta_mass, atom_str 
      # TODO -- check average mass
    end    
  end
  
end
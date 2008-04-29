require File.join(File.dirname(__FILE__), '../../constants_test_helper.rb') 
require 'constants/library/particle'

class ParticleTest < Test::Unit::TestCase
  include Constants::Library
  
  #
  # initialize test
  #
  
  def test_initialize
    c = Particle::CHARM

    assert_equal "Charm", c.name
    assert_equal "Fermion", c.family
    assert_equal "Quark", c.group
    assert_equal "Second", c.generation
    assert_equal 2.0/3, c.charge
    assert_equal 0.5, c.spin

    t = Particle::ANTITAU

    assert_equal "Anti-Tau", t.name
    assert_equal "Fermion", t.family
    assert_equal "Lepton", t.group
    assert_equal "Third", t.generation
    assert_equal -1, t.charge
    assert_equal 0.5, t.spin
  end
  
  #
  # lookup test
  #
  
  def test_lookup
    c = Particle::CHARM
    assert_equal c, Particle['Charm']
  end
  
  def test_lookup_is_nil_for_undefined_particles
    assert_nil Particle['Blop']
  end
end
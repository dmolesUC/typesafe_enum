require 'spec_helper'

class Suit < TypesafeEnum::Base
  define :CLUBS
  define :DIAMONDS
  define :HEARTS
  define :SPADES
end

class Tarot < TypesafeEnum::Base
  define :CUPS, 'Cups'
  define :COINS, 'Coins'
  define :WANDS, 'Wands'
  define :SWORDS, 'Swords'
end

module TypesafeEnum
  describe Base do

    describe '::define' do
      it 'defines a constant enum value' do
        enum = Suit::CLUBS
        expect(enum).to be_a(Suit)
      end

      it 'insists symbols be symbols' do
        expect do
          class Cheat < Base
            define 'spades', 'spades'
          end
        end.to raise_error(TypeError)
      end

      it 'insists symbols be uppercase' do
        expect do
          class Cheat < Base
            define :spades, 'spades'
          end
        end.to raise_error(NameError)
      end

      it 'disallows duplicate symbols' do
        expect do
          class Cheat < Base
            define :SPADES, 'spades'
            define :SPADES, 'more spades'
          end
        end.to raise_error(NameError)

        expect { Cheat.class }.to raise_error(NameError)
      end

      it 'disallows duplicate names' do
        expect do
          class Cheat < Base
            define :SPADES, 'spades'
            define :ALSO_SPADES, 'spades'
          end
        end.to raise_error(NameError)

        expect { Cheat.class }.to raise_error(NameError)
      end

      it 'defaults the name to a lower-cased version of the symbol' do
        expect(Suit::CLUBS.name).to eq('clubs')
        expect(Suit::DIAMONDS.name).to eq('diamonds')
        expect(Suit::HEARTS.name).to eq('hearts')
        expect(Suit::SPADES.name).to eq('spades')
      end

      it 'is private' do
        expect{Tarot.define(:PENTACLES)}.to raise_error(NoMethodError)
      end
    end

    describe '::to_a' do
      it 'returns the values as an array' do
        expect(Suit.to_a).to eq([Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES])
      end
      it 'returns a copy' do
        array = Suit.to_a
        array.clear
        expect(array.empty?).to eq(true)
        expect(Suit.to_a).to eq([Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES])
      end
    end

    describe '::length' do
      it 'returns the number of enum instnaces' do
        expect(Suit.length).to eq(4)
      end
    end

    describe '::each' do
      it 'iterates the enum values' do
        expected = [Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES]
        index = 0
        Suit.each do |s|
          expect(s).to be(expected[index])
          index += 1
        end
      end
    end

    describe '::each_with_index' do
      it 'iterates the enum values with indices' do
        expected = [Suit::CLUBS, Suit::DIAMONDS, Suit::HEARTS, Suit::SPADES]
        Suit.each_with_index do |s, index|
          expect(s).to be(expected[index])
        end
      end
    end

    describe '#<=>' do
      it 'orders enum instances' do
        Suit.each_with_index do |s1, i1|
          Suit.each_with_index do |s2, i2|
            expect(s1 <=> s2).to eq(i1 <=> i2)
          end
        end
      end
    end

    describe '#==' do
      it 'returns true for identical instances, false otherwise' do
        Suit.each do |s1|
          Suit.each do |s2|
            identical = s1.equal?(s2)
            expect(s1 == s2).to eq(identical)
          end
        end
      end

      it 'reports instances as unequal to nil and other objects' do
        a_nil_value = nil
        Suit.each do |s|
          expect(s.nil?).to eq(false)
          expect(s == a_nil_value).to eq(false)
          Tarot.each do |t|
            expect(s == t).to eq(false)
            expect(t == s).to eq(false)
          end
        end
      end

      it 'survives marshalling' do
        Suit.each do |s1|
          dump = Marshal.dump(s1)
          s2 = Marshal.load(dump)
          expect(s1 == s2).to eq(true)
          expect(s2 == s1).to eq(true)
        end
      end
    end

    describe '#!=' do
      it 'returns false for identical instances, true otherwise' do
        Suit.each do |s1|
          Suit.each do |s2|
            different = !s1.equal?(s2)
            expect(s1 != s2).to eq(different)
          end
        end
      end

      it 'reports instances as unequal to nil and other objects' do
        a_nil_value = nil
        Suit.each do |s|
          expect(s != a_nil_value).to eq(true)
          Tarot.each do |t|
            expect(s != t).to eq(true)
            expect(t != s).to eq(true)
          end
        end
      end
    end

    describe '#hash' do
      it 'gives consistent values' do
        Suit.each do |s1|
          Suit.each do |s2|
            expect(s1.hash == s2.hash).to eq(s1 == s2)
          end
        end
      end

      it 'returns different values for different types' do
        class Suit2 < Base
          define :CLUBS, 'Clubs'
          define :DIAMONDS, 'Diamonds'
          define :HEARTS, 'Hearts'
          define :SPADES, 'Spades'
        end

        Suit.each do |s1|
          s2 = Suit2[s1.key]
          expect(s1.hash == s2.hash).to eq(false)
        end
      end

      it 'survives marshalling' do
        Suit.each do |s1|
          dump = Marshal.dump(s1)
          s2 = Marshal.load(dump)
          expect(s2.hash).to eq(s1.hash)
        end
      end
    end

    describe '#eql?' do
      it 'is consistent with #hash' do
        Suit.each do |s1|
          Suit.each do |s2|
            expect(s1.eql?(s2)).to eq(s1.hash == s2.hash)
          end
        end
      end
    end

    describe '#name' do
      it 'returns the string name of the enum instance' do
        expected = %w(Clubs Diamonds Hearts Spades)
        Suit.each_with_index do |s, index|
          expect(s.name).to eq(expected[index])
        end
      end
    end

    describe '#key' do
      it 'returns the symbol key of the enum instance' do
        expected = [:CLUBS, :DIAMONDS, :HEARTS, :SPADES]
        Suit.each_with_index do |s, index|
          expect(s.key).to eq(expected[index])
        end
      end
    end

    describe '#ordinal' do
      it 'returns the ordinal value of the enum instance' do
        Suit.each_with_index do |s, index|
          expect(s.ordinal).to eq(index)
        end
      end
    end

    describe '::[]' do
      it 'maps symbol keys to enum instances' do
        keys = [:CLUBS, :DIAMONDS, :HEARTS, :SPADES]
        expected = Suit.to_a
        keys.each_with_index do |k, index|
          expect(Suit[k]).to be(expected[index])
        end
      end

      it 'maps names to enum instances' do
        names = %w(Clubs Diamonds Hearts Spades)
        expected = Suit.to_a
        names.each_with_index do |n, index|
          expect(Suit[n]).to be(expected[index])
        end
      end

      it 'maps ordinal indices to enum instances' do
        Suit.each do |s|
          expect(Suit[s.ordinal]).to be(s)
        end
      end

      it 'supports negative indices' do
        Suit.each_with_index do |s, index|
          negative_index = index - Suit.length
          expect(Suit[negative_index]).to be(s)
        end
      end

      it 'returns nil for invalid keys' do
        expect(Suit[:WANDS]).to be_nil
      end

      it 'returns nil for invalid names' do
        expect(Suit['wands']).to be_nil
      end

      it 'returns nil for invalid indices' do
        expect(Suit[100]).to be_nil
      end

    end

  end
end

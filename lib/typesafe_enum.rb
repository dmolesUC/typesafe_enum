# frozen_string_literal: true

module TypesafeEnum
  Dir.glob(File.expand_path('../typesafe_enum/*.rb', __FILE__)).sort.each(&method(:require))
end

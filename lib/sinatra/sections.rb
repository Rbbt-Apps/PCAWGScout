class EntityCard
  attr_accessor :sections

  def sections
    @sections ||= IndiferentHash.setup({})
  end

  def add_section(name, &block)
    sections[name] = block
  end

end

class EntityListCard
  attr_accessor :sections

  def sections
    @sections ||= IndiferentHash.setup({})
  end

  def add_section(name, &block)
    sections[name] = block
  end

end

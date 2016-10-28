module StructuralVariant
  extend Entity
  include Entity::REST

  self.annotation :organism

  self.format = ["Structural Variant", "SV"]

  property :_parts => :single do
    self.split(":")
  end

  property :chr1 => :single do
    _parts[0]
  end

  property :pos1 => :single do
    _parts[1]
  end

  property :type => :single do
    _parts[2]
  end
  
  property :chr2 => :single do
    _parts[3]
  end

  property :pos2 => :single do
    _parts[4]
  end
  
  property :left_range => :single do |size=nil|
    size = 1_000 if size.nil?
    chr1, pos1, type, chr2, pos2 = self.split(":")
    [chr1, pos1.to_i - size, pos1.to_i + size] * ":"
  end

  property :right_range => :single do |size=nil|
    size = 1_000 if size.nil?
    chr1, pos1, type, chr2, pos2 = self.split(":")
    [chr2, pos2.to_i - size, pos2.to_i + size] * ":"
  end
  
  
  property :left_genes => :array2single do |size=nil|
    left_range = self.left_range
    Sequence.job(:genes_at_ranges, nil, :ranges => left_range, :organism => organism).run.values_at *left_range
  end

  property :right_genes => :array2single do |size=nil|
    right_range = self.right_range
    Sequence.job(:genes_at_ranges, nil, :ranges => right_range, :organism => organism).run.values_at *right_range
  end

  property :genes => :single do |size=nil|
    genes = (left_genes(size) || []) + (right_genes(size) || [])
    Gene.setup(genes, "Ensembl Gene ID", organism)
  end
end


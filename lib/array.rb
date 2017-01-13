class Array
  def from_labels
    Hash[self.map{|item| item.split('=').map(&:strip)}].from_labels
  end

  def to_hcl
    self.map(&:to_hcl).join(",\n") + ","
  end

  def merge(other_array)
    (self + other_array).uniq
  end
end

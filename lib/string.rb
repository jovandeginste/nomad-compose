class String
  def join(*param)
    return self
  end
  def to_a
    require 'csv'

    CSV::parse_line(self, col_sep: ' ')
  end
end

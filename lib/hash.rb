class Hash
  alias :+ :merge

  def level_merge(other_hash)
    other_hash.each do |key, value|
      if self[key]
	self[key] = value.merge(self[key])
      else
	self[key] = value
      end
    end
  end

  def to_hcl
    result = []
    self.collect do |key, value|
      next if key.to_s == '_type'
      case value.class.to_s
      when 'NilClass'
	# nothing
      when 'Array'
	result << "#{key} = ["
	result << value.to_hcl.gsub(/^/, '  ')
	result << "]"
      when 'Hash'
	if type = value['_type'] || value[:_type]
	  if key.match(/^_/)
	    result << "#{type} {"
	  else
	    result << "#{type} \"#{key}\" {"
	  end
	  result << value.to_hcl.gsub(/^/, '  ')
	  result << "}"
	else
	  result << "#{key} {"
	  result << value.to_hcl.gsub(/^/, '  ')
	  result << "}"
	end
      else
	result << "#{key} = #{value.to_hcl}"
      end
    end
    return result.join("\n")
  end

  def from_labels
    result = {}
    self.each do |key, value|
      split_key = key.strip.split('.')

      sub_key = result
      sub_key = sub_key[split_key.shift] ||= {} until split_key.size == 1
      sub_key[split_key.shift] = value
    end
    return result
  end
end

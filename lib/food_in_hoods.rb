class Array
  def blank_inside?
    self.reject(&:blank?).blank?
  end
end

class String
  def initial
    self[0,1]
  end
end

class ActiveRecord::Relation
  def paginate page, per_page
    page(page).per(per_page)
  end
end

class Hash
  def camelize_keys! value = self
    case value
    when Array
      value.map { |v| camelize_keys! v }
    when Hash
      Hash[value.map { |k, v| [k.to_s.camelize(:lower).to_sym,  camelize_keys!(v)] }]
    else
      value
    end
  end
end

class Convert
  def self.dollars_to_cents amount
    (amount.to_f * 100).round
  end

  def self.cents_to_dollars amount
    amount.to_f / 100
  end
end

module Enumerable
  def each_with_previous
    self.inject(nil) { |prev, curr| yield prev, curr; curr }
    self
  end
end

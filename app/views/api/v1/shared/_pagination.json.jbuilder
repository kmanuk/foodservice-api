if defined?(@pagination)
  json.pagination do
    json.page        @pagination.page
    json.limit       @pagination.limit
    json.total       @pagination.total
    json.total_pages @pagination.total_pages
  end
end

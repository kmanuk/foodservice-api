module ApplicationHelper

  def pagination(page, limit, total, total_pages)
    @pagination = OpenStruct.new(
        page: page,
        limit: limit,
        total: total,
        total_pages: total_pages
    )
  end

end

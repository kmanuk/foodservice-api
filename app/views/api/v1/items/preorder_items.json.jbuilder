json.sellers @sellers do |seller|
  json.partial! 'api/v1/users/seller', user: seller
  json.video_snapshot_url asset_url seller.video_snapshot_url
  json.video_url asset_url seller.video_url
  json.video_snapshot_thumb seller.video_snapshot_thumb

  json.item do
    if seller.find_preorder_item
      json.partial! 'item', item: seller.find_preorder_item
    else
      json.null!
    end
  end
end

json.partial! 'api/v1/shared/pagination'

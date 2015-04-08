class CollectionSerializer < BaseSerializer
  schema do
    paging.to_hash.each do |key, value|
      property key, value
    end

    entities :collection, item, collection_serializer_class, collection_serializer_context

    link :first, href: ""
    link :previous, href: ""
    link :self, href: ""
    link :next, href: ""
    link :last, href: ""

    add_actions unless actions_not_provided
  end

  protected

  def add_actions
    context[:actions].each do |key, value|
      link key.to_sym, value
    end
  end

  def actions_not_provided
    context[:actions].nil? || context[:actions].empty?
  end

  def collection_serializer_context
    context
  end

  def collection_serializer_class
    context.fetch(:serializer_class)
  end

  def paging
    page = context.fetch(:page) { 1 }
    page_size = context.fetch(:page_size) { 100 }

    @paging ||= CollectionPaging.new(total_records: context.fetch(:total_records), page_size: page_size, page: page)
  end
end

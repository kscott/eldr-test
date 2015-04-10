class CollectionPaging
  attr_reader :total_records, :page, :page_size

  def initialize(total_records:, page: 1, page_size: 100)
    @total_records = total_records
    @page = page
    @page_size = page_size
  end


  def record_start
    ((page - 1) * page_size) + 1
  end

  def record_end
    [(record_start + page_size) - 1, total_records].min
  end

  def record_count
    record_end - record_start + 1
  end

  def total_pages
    (total_records.to_f/page_size.to_f).ceil
  end

  def to_hash
    {
      total_records: total_records,
      page: page,
      page_size: page_size,
      record_start: record_start,
      record_end: record_end,
      record_count: record_count,
      total_pages: total_pages
    }
  end
end

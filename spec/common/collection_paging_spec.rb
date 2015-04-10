describe CollectionPaging do
  subject {
    described_class.new(
      total_records: total_records,
      page: page,
      page_size: page_size
    ).to_hash
  }
  let (:total_records) { 97 }
  let (:page) { 5 }
  let (:page_size) { 20 }
  let (:record_start) { 81 }
  let (:record_end) { 97 }
  let (:record_count) { 17 }
  let (:total_pages) { 5 }

  context "will contain valid properties" do
    [:total_records, :page, :page_size, :record_start, :record_end, :record_count, :total_pages].each do |key|
      it key do
        expect(subject.fetch(key)).to eq(self.send(key))
      end
    end
  end
end

describe CollectionSerializer do
  subject {
    described_class.new(
      group_collection,
      current_individual: Church::Individual.new(id: 1, first_name: "Master", last_name: "Admin"),
      serializer_class: Church::MyGroupSerializer,
      total_records: 987,
      page: 1,
      page_size: 100
    )
  }

  let (:group_collection) {[Church::Group.new(id: 1, name: "Group 1"), Church::Group.new(id: 2, name: "Group 2")]}
  let (:total_records) { 987 }
  let (:page) { 1 }
  let (:page_size) { 100 }
  let (:record_start) { 1 }
  let (:record_end) { 100 }
  let (:record_count) { 100 }
  let (:total_pages) { 10 }

  it "has a collection" do
    expect(subject.to_hash[:collection]).not_to be_empty
  end

  context "will contain valid properties" do
    [:total_records, :page, :page_size, :record_start, :record_end, :record_count, :total_pages].each do |key|
      it key do
        expect(subject.to_hash.fetch(key)).to eq(self.send(key))
      end
    end
  end
end

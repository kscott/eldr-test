describe Church::QueueSerializer do
  let(:queue) { Church::Queue.find(33) }
  subject(:serializer) { described_class.new(queue).to_hash }

  it_behaves_like "a basic queue profile"
end

RSpec.describe Slcsp::IdentifyPlan do
  before(:all) do
    Slcsp::IdentifyPlan.new.find_slcsp
  end
  let(:returned_csv) { CSV.read('vendor/slcsp-with-rates.csv', headers: true) }

  it "generates a CSV with rates" do
    expect(returned_csv[0]['rate']).not_to be nil
  end

  it "maintains the order of the rows" do
    expect(returned_csv[0]['zipcode']).to eq '64148'
    expect(returned_csv[50]['zipcode']).to eq '31551'
  end

  it "returns the second lowest cost plan" do
    expect(returned_csv[0]['rate']).to eq '245.2'
  end

  it "returns nil when zip code is in more than one rate area" do
    expect(returned_csv[6]['rate']).to eq nil
  end
end

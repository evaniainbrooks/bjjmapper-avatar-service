# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe 'AvatarService::Application' do
  ['users', 'teams', 'locations'].each do |upload_type|
    describe "POST /upload/#{upload_type}/:id/async" do
      context 'with file upload' do 
        let(:expected_id) { '1234' }
        let(:file) {  Rack::Test::UploadedFile.new(File.expand_path('../fixtures/test_upload.png', __FILE__), 'image/png') }
        it 'enqueues a file upload job' do
          "#{upload_type.slice(0..-2)}ImageUploader".camelize.constantize.should_receive(:store_async).with(expected_id, anything) 

          post "/upload/#{upload_type}/#{expected_id}/async", :file => file 
          last_response.status.should eq 202
        end
      end
    end
  end
end

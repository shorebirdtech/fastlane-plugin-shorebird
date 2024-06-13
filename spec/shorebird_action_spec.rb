describe Fastlane::Actions::ShorebirdAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The shorebird plugin is working!")

      Fastlane::Actions::ShorebirdAction.run(nil)
    end
  end
end

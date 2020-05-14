require "../spec_helper"

describe IO::FileDescriptor do
  it "reopen STDIN with the right mode" do
    code = %q(puts "#{STDIN.blocking} #{STDIN.info.type}")
    compile_source(code) do |binpath|
      `#{binpath} < #{binpath}`.chomp.should eq("true File")
      `echo "" | #{binpath}`.chomp.should eq("false Pipe")
    end
  end
end

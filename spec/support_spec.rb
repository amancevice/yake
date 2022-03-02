RSpec.describe Hash do
  subject { { 'fizz' => 'buzz' } }

  context '#encode64' do
    it 'should transform a Hash to a Base64-encoded string' do
      expect(subject.encode64).to eq "eyJmaXp6IjoiYnV6eiJ9\n"
    end
  end

  context '#strict_encode64' do
    it 'should transform a Hash to a strict Base64-encoded string' do
      expect(subject.strict_encode64).to eq 'eyJmaXp6IjoiYnV6eiJ9'
    end
  end

  context '#symbolize_names' do
    it 'should convert the keys of a Hash to symbols' do
      expect(subject.symbolize_names).to eq fizz: 'buzz'
    end
  end

  context '#to_form' do
    it 'should convert the Hash to a web form' do
      expect(subject.to_form).to eq 'fizz=buzz'
    end
  end
end

RSpec.describe Integer do
  subject { 1_234_567_890 }

  context '#weeks' do
    it 'should convert the Integer from weeks to seconds' do
      expect(subject.weeks).to eq 746_666_659_872_000
    end
  end

  context '#days' do
    it 'should convert the Integer from days to seconds' do
      expect(subject.days).to eq 106_666_665_696_000
    end
  end

  context '#hours' do
    it 'should convert the Integer from hours to seconds' do
      expect(subject.hours).to eq 4_444_444_404_000
    end
  end

  context '#minutes' do
    it 'should convert the Integer from minutes to seconds' do
      expect(subject.minutes).to eq 74_074_073_400
    end
  end

  context '#seconds' do
    it 'should convert the Integer from seconds to seconds' do
      expect(subject.seconds).to eq 1_234_567_890
    end
  end

  context '#utc' do
    it 'should convert the Integer to a Time object in the UTC timezone' do
      expect(subject.utc).to eq Time.at(subject).utc
    end
  end
end

RSpec.describe String do
  context '#/' do
    it 'should concat the path parts' do
      expect('https://example.com/'/'/path/to/resource/').to eq 'https://example.com/path/to/resource/'
    end
  end

  context '#camel_case' do
    it 'should convert a snake_case String to CamelCase' do
      expect('snake_case_string'.camel_case).to eq 'SnakeCaseString'
    end
  end

  context '#decode64' do
    it 'should decode the String from Base64' do
      expect("eyJmaXp6IjoiYnV6eiJ9\n".decode64).to eq '{"fizz":"buzz"}'
    end
  end

  context '#encode64' do
    it 'should encode the String to Base64' do
      expect('{"fizz":"buzz"}'.encode64).to eq "eyJmaXp6IjoiYnV6eiJ9\n"
    end
  end

  context '#snake_case' do
    it 'should convert the String from CamelCase to snake_case' do
      expect('SnakeCaseString'.snake_case).to eq 'snake_case_string'
    end
  end

  context '#strict_decode64' do
    it 'should decode the String from Base64' do
      expect("eyJmaXp6IjoiYnV6eiJ9".strict_decode64).to eq '{"fizz":"buzz"}'
    end
  end

  context '#strict_encode64' do
    it 'should encode the String to Base64' do
      expect('{"fizz":"buzz"}'.strict_encode64).to eq "eyJmaXp6IjoiYnV6eiJ9"
    end
  end

  context '#to_h_from_json' do
    it 'should convert the JSON String to a Hash' do
      expect('{"fizz":"buzz"}'.to_h_from_json).to eq 'fizz' => 'buzz'
    end
  end

  context '#to_h_from_form' do
    it 'should convert the form String to a Hash' do
      expect('fizz=buzz'.to_h_from_form).to eq 'fizz' => 'buzz'
    end
  end
end

RSpec.describe Symbol do
  context '#camel_case' do
    it 'should convert a snake_case String to CamelCase' do
      expect(:snake_case_symbol.camel_case).to eq :SnakeCaseSymbol
    end
  end

  context '#snake_case' do
    it 'should convert the String from CamelCase to snake_case' do
      expect(:SnakeCaseSymbol.snake_case).to eq :snake_case_symbol
    end
  end
end

RSpec.describe UTC do
  context '::at' do
    it 'should interpret an Integer as a Time in UTC' do
      expect(UTC.at 1234567890).to eq Time.at(1234567890).utc
    end
  end

  context '::now' do
    it 'should consruct the current time in UTC' do
      expect(UTC.now.iso8601).to eq Time.now.utc.iso8601
    end
  end
end

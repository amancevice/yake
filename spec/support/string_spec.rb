# frozen_string_literal: true

RSpec.describe String do
  context '#/' do
    it 'should concat the path parts' do
      expect('https://example.com/' / '/path/to/resource/').to eq 'https://example.com/path/to/resource/'
    end
  end

  context '#camel_case' do
    it 'should convert a snake_case String to CamelCase' do
      expect('snake_case_string'.camel_case).to eq 'SnakeCaseString'
    end

    it 'should convert a snake_case String (with spaces) to CamelCase (without spaces)' do
      expect('snake case string'.camel_case).to eq 'SnakeCaseString'
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

  context '#md5sum' do
    it 'should return the MD5 checksum of the string' do
      expect('fizz'.md5sum).to eq 'b6bfa6c318811be022d4f73070597660'
    end
  end

  context '#sha1sum' do
    it 'should return the SHA1 checksum of the string' do
      expect('fizz'.sha1sum).to eq 'c25f5985f2ab63baeb2408a2d7dbc79d8f29d02f'
    end
  end

  context '#snake_case' do
    it 'should convert the String from CamelCase to snake_case' do
      expect('SnakeCaseString'.snake_case).to eq 'snake_case_string'
    end

    it 'should convert the String from CamelCase (with spaces) to snake_case (without spaces)' do
      expect('Snake Case String'.snake_case).to eq 'snake_case_string'
    end
  end

  context '#strict_decode64' do
    it 'should decode the String from Base64' do
      expect('eyJmaXp6IjoiYnV6eiJ9'.strict_decode64).to eq '{"fizz":"buzz"}'
    end
  end

  context '#strict_encode64' do
    it 'should encode the String to Base64' do
      expect('{"fizz":"buzz"}'.strict_encode64).to eq 'eyJmaXp6IjoiYnV6eiJ9'
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

  context '#utc' do
    it 'should parse a string as a UTC time' do
      expect('2009-02-13T23:31:30Z'.utc.to_i).to eq 1_234_567_890
    end
  end
end

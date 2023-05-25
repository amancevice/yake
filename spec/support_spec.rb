RSpec.describe Hash do
  subject do
    {
      'fizz' => 'buzz',
      'jazz' => 'fuzz',
      'razz' => [{'mtaz' => 'hazz'}],
      'wizz' => { 'kizz' => 'kazz'},
    }
  end

  context '#deep_*' do
    subject { { f: 'g', a: { d: 'e', b: 'c' } } }

    context '#deep_keys' do
      it 'should return all the keys in the nested Hash' do
        expect(subject.deep_keys).to eq %i[f a d b]
      end
    end

    context '#deep_merge' do
      it 'should deeply merge two objects' do
        left  = { a: 'b', c: { d: %w[e] } }
        right = { a: 'a', c: { d: %w[d] } }
        both  = { a: 'a', c: { d: %w[e d] } }
        expect(left.deep_merge(right)).to eq both
      end

      it 'should deeply merge two objects with a block' do
        left  = { a: 'b', c: { d: %w[e] } }
        right = { a: 'a', c: { d: %w[d] } }
        both  = { a: 'a', c: { d: %w[e d] } }
        expect(left.deep_merge(right) { |k,a,b| b }).to eq both
      end
    end

    context '#deep_sort' do
      it 'should sort the Hash before converting to JSON' do
        expect(subject.deep_sort).to eq(a: { b: 'c', d: 'e' }, f: 'g')
      end
    end

    context '#deep_transform_keys' do
      it 'should transform the keys' do
        expect(subject.deep_transform_keys(&:to_s)).to eq subject.to_json.to_h_from_json
      end

      it 'should do nothing' do
        expect(subject.deep_transform_keys).to eq subject
      end
    end

    context '#deep_transform_keys!' do
      let(:subject_clone) { subject.deep_transform_keys(&:to_s) }

      it 'should transform the keys deeply in place' do
        subject_clone.deep_transform_keys!(&:to_sym)
        expect(subject_clone).to eq subject
      end

      it 'should do nothing' do
        expect(subject_clone.deep_transform_keys!).to eq subject_clone
      end
    end
  end

  context '#encode64' do
    it 'should transform a Hash to a Base64-encoded string' do
      expect(subject.encode64).to eq "eyJmaXp6IjoiYnV6eiIsImphenoiOiJmdXp6IiwicmF6eiI6W3sibXRheiI6\nImhhenoifV0sIndpenoiOnsia2l6eiI6ImthenoifX0=\n"
    end
  end

  context '#except' do
    it 'should return a new Hash without the provided keys' do
      expect(subject.except('fizz', 'razz')).to eq('jazz' => 'fuzz', 'wizz' => { 'kizz' => 'kazz' })
    end
  end

  context '#strict_encode64' do
    it 'should transform a Hash to a strict Base64-encoded string' do
      expect(subject.strict_encode64).to eq 'eyJmaXp6IjoiYnV6eiIsImphenoiOiJmdXp6IiwicmF6eiI6W3sibXRheiI6ImhhenoifV0sIndpenoiOnsia2l6eiI6ImthenoifX0='
    end
  end

  context '#stringify_names' do
    it 'should convert the keys of a Hash to strings' do
      expect(subject.symbolize_names.stringify_names).to eq subject
    end
  end

  context '#stringify_names!' do
    let(:subject_clone) { JSON.parse subject.to_json, symbolize_names: true }

    it 'should convert the keys of a Hash to strings in place' do
      subject_clone.stringify_names!
      expect(subject_clone).to eq subject
    end
  end

  context '#symbolize_names' do
    it 'should convert the keys of a Hash to symbols' do
      expect(subject.symbolize_names).to eq(
        fizz: 'buzz',
        jazz: 'fuzz',
        razz: [ { mtaz: 'hazz' } ],
        wizz: { kizz: 'kazz' },
      )
    end
  end

  context '#symbolize_names!' do
    let(:subject_clone) { JSON.parse subject.to_json }

    it 'should convert the keys of a Hash to symbols in place' do
      subject_clone.symbolize_names!
      expect(subject_clone).to eq subject.deep_transform_keys(&:to_sym)
    end
  end

  context '#to_deep_struct' do
    it 'should convert the Hash to a nested OpenStruct' do
      expect(subject.to_deep_struct.razz.first.mtaz).to eq 'hazz'
    end
  end

  context '#to_form' do
    it 'should convert the Hash to a web form' do
      expect(subject.to_form).to eq 'fizz=buzz&jazz=fuzz&razz=%7B%22mtaz%22%3D%3E%22hazz%22%7D&wizz=%7B%22kizz%22%3D%3E%22kazz%22%7D'
    end
  end

  context '#to_json_sorted' do
    subject { { f: 'g', a: { d: 'e', b: 'c' } } }

    it 'should sort the Hash before converting to JSON' do
      expect(subject.to_json_sorted).to eq '{"a":{"b":"c","d":"e"},"f":"g"}'
    end
  end

  context '#to_dynamodb' do
    subject do
      {
        a: 'b',
        c: 1,
        d: ['e', 2.3],
        f: { g: 'h' }
      }
    end

    it 'should convert the Hash to DynamoDB format' do
      expect(subject.to_dynamodb).to eq(
        a: { S: 'b' },
        c: { N: '1' },
        d: { L: [ { S: 'e' }, { N: '2.3' } ] },
        f: { M: { g: { S: 'h'} } },
      )
    end
  end

  context '#from_dynamodb' do
    subject do
      {
        a: { S: 'b' },
        c: { N: '1' },
        d: { L: [ { S: 'e' }, { N: '2.3' } ] },
        f: { M: { g: { S: 'h'} } },
      }
    end

    it 'should convert the Hash to DynamoDB format' do
      expect(subject.to_h_from_dynamodb).to eq(
        a: 'b',
        c: 1,
        d: ['e', 2.3],
        f: { g: 'h' },
      )
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

RSpec.describe Object do
  subject { 'Hello, World!' }

  context '#try' do
    it 'should try (and succeed) to execute the given method' do
      expect(subject.try :encode, 'ascii').to eq subject
    end

    it 'should try (and fail) to execute the given method' do
      expect(subject.try :fizz).to be nil
    end

    it 'should try (and fail) to execute the given method and yield' do
      expect(subject.try(:fizz) { |x| x.sub 'Hello', 'Goodbye' }).to eq 'Goodbye, World!'
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

  context '#utc' do
    it 'should parse a string as a UTC time' do
      expect('2009-02-13T23:31:30Z'.utc.to_i).to eq 1234567890
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

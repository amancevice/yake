# frozen_string_literal: true

RSpec.describe Hash do
  subject do
    {
      'fizz' => 'buzz',
      'jazz' => 'fuzz',
      'razz' => [{ 'mtaz' => 'hazz' }],
      'wizz' => { 'kizz' => 'kazz' }
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
        expect(left.deep_merge(right) { |*_, b| b }).to eq both
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
      expect(subject.encode64).to eq Base64.encode64(subject.to_json)
    end
  end

  context '#pluck' do
    it 'should return a list of the plucked values' do
      expect(([subject] * 3).pluck('fizz')).to eq(%w[buzz] * 3)
    end
  end

  context '#strict_encode64' do
    it 'should transform a Hash to a strict Base64-encoded string' do
      expect(subject.strict_encode64).to eq Base64.strict_encode64(subject.to_json)
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
        razz: [{ mtaz: 'hazz' }],
        wizz: { kizz: 'kazz' }
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
    it 'should convert the Hash to a nested struct' do
      expect(subject.to_deep_struct.razz.first.mtaz).to eq 'hazz'
    end
  end

  context '#to_form' do
    it 'should convert the Hash to a web form' do
      expect(subject.to_form).to eq URI.encode_www_form(subject)
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
        d: { L: [{ S: 'e' }, { N: '2.3' }] },
        f: { M: { g: { S: 'h' } } }
      )
    end
  end

  context '#from_dynamodb' do
    subject do
      {
        a: { S: 'b' },
        c: { N: '1' },
        d: { L: [{ S: 'e' }, { N: '2.3' }] },
        f: { M: { g: { S: 'h' } } }
      }
    end

    it 'should convert the Hash to DynamoDB format' do
      expect(subject.to_h_from_dynamodb).to eq(
        a: 'b',
        c: 1,
        d: ['e', 2.3],
        f: { g: 'h' }
      )
    end
  end
end

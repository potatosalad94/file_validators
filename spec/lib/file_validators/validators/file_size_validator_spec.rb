require 'spec_helper'
require 'file_validators/validators/file_size_validator'

describe ActiveModel::Validations::FileSizeValidator do
  class Dummy
    include ActiveModel::Validations
  end

  def storage_units
    if defined?(ActiveSupport::NumberHelper) # Rails 4.0+
      { 5120 => '5 KB',       10240 => '10 KB' }
    else
      { 5120 => '5120 Bytes', 10240 => '10240 Bytes' }
    end
  end

  before :all do
    @storage_units = storage_units
  end

  subject { Dummy }

  def build_validator(options)
    @validator = ActiveModel::Validations::FileSizeValidator.new(options.merge(attributes: :avatar))
  end

  context 'with :in option' do
    context 'as a range' do
      before { build_validator in: (5.kilobytes..10.kilobytes) }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator in: lambda { |record| (5.kilobytes..10.kilobytes) } }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end
  end

  context 'with :greater_than_or_equal_to option' do
    context 'as a number' do
      before { build_validator greater_than_or_equal_to: 10.kilobytes }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(9.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator greater_than_or_equal_to: lambda { |record| 10.kilobytes } }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(9.kilobytes, @validator) }
    end
  end

  context 'with :less_than_or_equal_to option' do
    context 'as a number' do
      before { build_validator less_than_or_equal_to: 10.kilobytes }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator less_than_or_equal_to: lambda { |record| 10.kilobytes } }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end
  end

  context 'with :greater_than option' do
    context 'as a number' do
      before { build_validator greater_than: 10.kilobytes }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator greater_than: lambda { |record| 10.kilobytes } }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :less_than option' do
    context 'as a number' do
      before { build_validator less_than: 10.kilobytes }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator less_than: lambda { |record| 10.kilobytes } }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :greater_than and :less_than option' do
    context 'as a number' do
      before { build_validator greater_than: 5.kilobytes, less_than: 10.kilobytes }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(5.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator greater_than: lambda { |record| 5.kilobytes },
                                  less_than: lambda { |record| 10.kilobytes } }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(5.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :message option' do
    before { build_validator in: (5.kilobytes..10.kilobytes),
                             message: 'is invalid. (Between %{min} and %{max} please.)' }

    it { is_expected.not_to allow_file_size(11.kilobytes, @validator,
                                            message: "Avatar is invalid. (Between #{@storage_units[5120]} and #{@storage_units[10240]} please.)") }

    it { is_expected.to allow_file_size(7.kilobytes, @validator,
                                        message: "Avatar is invalid. (Between #{@storage_units[5120]} and #{@storage_units[10240]} please.)") }
  end

  context 'default error message' do
    context 'given :in options' do
      before { build_validator in: 5.kilobytes..10.kilobytes }

      it { is_expected.not_to allow_file_size(11.kilobytes, @validator,
                                              message: "Avatar file size must be between #{@storage_units[5120]} and #{@storage_units[10240]}") }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator,
                                              message: "Avatar file size must be between #{@storage_units[5120]} and #{@storage_units[10240]}") }
    end

    context 'given :greater_than and :less_than options' do
      before { build_validator greater_than: 5.kilobytes, less_than: 10.kilobytes }

      it { is_expected.not_to allow_file_size(11.kilobytes, @validator,
                                              message: "Avatar file size must be less than #{@storage_units[10240]}") }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator,
                                              message: "Avatar file size must be greater than #{@storage_units[5120]}") }
    end

    context 'given :greater_than_or_equal_to and :less_than_or_equal_to options' do
      before { build_validator greater_than_or_equal_to: 5.kilobytes, less_than_or_equal_to: 10.kilobytes }

      it { is_expected.not_to allow_file_size(11.kilobytes, @validator,
                                              message: "Avatar file size must be less than or equal to #{@storage_units[10240]}") }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator,
                                              message: "Avatar file size must be greater than or equal to #{@storage_units[5120]}") }
    end
  end


  context 'using the helper' do
    before { Dummy.validates_file_size :avatar, in: (5.kilobytes..10.kilobytes) }

    it 'adds the validator to the class' do
      expect(Dummy.validators_on(:avatar)).to include(ActiveModel::Validations::FileSizeValidator)
    end
  end

  context 'given options' do
    it 'raises argument error if no required argument was given' do
      expect { build_validator message: 'Some message' }.to raise_error(ArgumentError)
    end

    (ActiveModel::Validations::FileSizeValidator::CHECKS.keys).each do |argument|
      it "does not raise argument error if #{argument} was given" do
        expect { build_validator argument => 5.kilobytes }.not_to raise_error
      end
    end

    it 'does not raise argument error if :in was given' do
      expect { build_validator in: (5.kilobytes..10.kilobytes) }.not_to raise_error
    end
  end
end

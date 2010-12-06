require 'spec_helper'

class Bar < ActiveRecord::Base
  devise :database_authenticatable, :stretches => 15, :encryptor => :clearance_sha1
end

describe Remarkable::Devise::Matchers::BeADatabaseAuthenticatableMatcher do
  before do
    @valid_columns = ['email', 'encrypted_password', 'password_salt']

    User.stubs(:column_names).returns(@valid_columns)
    Bar.stubs(:column_names).returns(@valid_columns)
  end

  context "inclusion of Devise::Models::DatabaseAuthenticatable" do
    it "should validate that model has Devise :database_authenticatable model" do
      subject.matches?(User).should be_true
    end

    it "should validate that model has no :database_authenticatable model" do
      subject.matches?(FooUser).should be_false
    end
  end

  context "options validation" do
    describe :stretches do
      it "should validate that a model has proper :stratches" do
        subject.class.new(:stretches => 15).matches?(Bar).should be_true
      end

      it "should validate that a model hasn't proper :stratches" do
        subject.class.new(:stretches => 10).matches?(Bar).should be_false
      end
    end

    describe :encryptor do
      it "should validate that a model has proper :encryptor" do
        subject.class.new(:encryptor => :clearance_sha1).matches?(Bar).should be_true
      end

      it "should validate that a model hasn't proper :encryptor" do
        subject.class.new(:encryptor => :bcrypt).matches?(Bar).should be_false
      end
    end
  end
  
  context "columns validation" do
    context "email column" do
      before do
        subject.stubs(:has_encrypted_password_column?).returns(true)
        subject.stubs(:has_password_salt_column?).returns(true)
      end

      it "should validate that model has email column" do
        subject.matches?(User).should be_true
      end

      it "should validate that model has no email column" do
        User.stubs(:column_names).returns(@valid_columns - ['email'])
        
        subject.matches?(User).should be_false
      end
    end

    context "encrypted_password column" do
      before do
        subject.stubs(:has_email_column?).returns(true)
        subject.stubs(:has_password_salt_column?).returns(true)
      end

      it "should validate that model has encrypted_password column" do
        subject.matches?(User).should be_true
      end

      it "should validate that model has no encrypted_password column" do
        User.stubs(:column_names).returns(@valid_columns - ['encrypted_password'])
        
        subject.matches?(User).should be_false
      end
    end

    context "password_salt column" do
      before do
        subject.stubs(:has_email_column?).returns(true)
        subject.stubs(:has_encrypted_password_column?).returns(true)
      end

      it "should validate that model has password_salt column" do
        subject.matches?(User).should be_true
      end

      it "should validate that model has no password_salt column" do
        User.stubs(:column_names).returns(@valid_columns - ['password_salt'])
        
        subject.matches?(User).should be_false
      end
    end
  end

  describe "description" do
    before do
      @msg = subject.description
    end
    
    specify { @msg.should eql('be a database authenticatable') }
  end

  context "expectation message" do
    context "when Devise::Models::DatabaseAuthenticatable not included" do
      before do
        subject.matches?(FooUser)
        
        @msg = subject.failure_message_for_should
      end
      
      specify { @msg.should match('to include Devise :database_authenticatable model') }
    end

    context "when model has no email column" do
      before do
        subject.stubs(:has_email_column?).returns(false)
        subject.matches?(User)

        @msg = subject.failure_message_for_should
      end

      specify { @msg.should match('to have email column') }
    end

    context "when model has no encrypted_password column" do
      before do
        subject.stubs(:has_encrypted_password_column?).returns(false)
        subject.matches?(User)

        @msg = subject.failure_message_for_should
      end

      specify { @msg.should match('to have encrypted_password column') }
    end

    context "when model has no password_salt column" do
      before do
        subject.stubs(:has_password_salt_column?).returns(false)
        subject.matches?(User)

        @msg = subject.failure_message_for_should
      end

      specify { @msg.should match('to have password_salt column') }
    end

    context "when :stretches doesn't match" do
      before do
        @matcher = subject.class.new(:stretches => 10)
        @matcher.matches?(Bar)
      end

      specify { @matcher.failure_message_for_should.should match('Bar to have password stretches equal to 10, got 15') }
    end

    context "when :encryptor doesn't match" do
      before do
        @matcher = subject.class.new(:encryptor => :bcrypt)
        @matcher.matches?(Bar)
      end

      specify { @matcher.failure_message_for_should.should match('Bar to have :bcrypt password encryptor, got :clearance_sha1') }
    end
  end
end

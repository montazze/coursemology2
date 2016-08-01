# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Course::Assessment::ProgrammingTestCaseReport do
  context 'when given a report containing multiple test suites' do
    self::REPORT_PATH = File.join(Rails.root,
                                  'spec/fixtures/course/programming_multiple_test_suite_report.xml')
    self::REPORT_XML = File.read(self::REPORT_PATH)

    let(:parsed_report) do
      Course::Assessment::ProgrammingTestCaseReport.new(self.class::REPORT_XML)
    end
    subject { parsed_report }

    describe '#test_suites' do
      it 'returns all the test suites in the report' do
        expect(subject.test_suites.length).to eq(2)
      end
    end

    describe '#test_cases' do
      it 'returns all the test cases in the report' do
        expect(subject.test_cases.length).to eq(3)
      end
    end

    describe Course::Assessment::ProgrammingTestCaseReport::TestSuite do
      subject { parsed_report.test_suites.second }

      describe '#name' do
        it 'returns the name attribute' do
          expect(subject.name).to eq('JUnitXmlReporter.constructor')
        end
      end

      describe '#identifier' do
        it 'generates an identifier for the test suite' do
          expect(subject.identifier).to eq(subject.name)
        end
      end

      describe '#duration' do
        it 'returns the time attribute' do
          expect(subject.duration).to eq(0.006)
        end
      end

      describe '#test_cases' do
        it 'returns all test cases in the suite' do
          expect(subject.test_cases.length).to eq(3)
        end
      end
    end

    describe Course::Assessment::ProgrammingTestCaseReport::TestCase do
      let(:test_cases) { parsed_report.test_suites.second.test_cases }
      subject { test_cases.first }

      describe '#class_name' do
        it 'returns the classname attribute' do
          expect(subject.class_name).to eq('JUnitXmlReporter.constructor')
        end
      end

      describe '#name' do
        it 'returns the name attribute' do
          expect(subject.name).to eq('should default path to an empty string')
        end
      end

      describe '#identifier' do
        it 'generates an identifier for the test suite' do
          expect(subject.identifier).to include(subject.test_suite.name)
          expect(subject.identifier).to include(subject.name)
        end

        context 'when the test case as a class name' do
          it 'uses the class name as part of the identifier' do
            expect(subject.identifier).to include(subject.class_name)
          end
        end

        context 'when the test case does not have a class name' do
          it 'still generates an identifier' do
            expect(subject.identifier).not_to be_nil
          end
        end
      end

      describe '#duration' do
        it 'returns the time attribute' do
          expect(subject.duration).to eq(0.006)
        end
      end

      context 'when the test case failed' do
        subject { test_cases.first }
        it { is_expected.to be_failed }
        it { is_expected.not_to be_passed }
      end

      context 'when the test case was skipped' do
        subject { test_cases.second }
        it { is_expected.to be_skipped }
        it { is_expected.not_to be_passed }
      end

      context 'when the test case passed' do
        subject { test_cases.third }
        it { is_expected.to be_passed }
      end
    end
  end

  context 'when given a report containing a single test suite' do
    self::REPORT_PATH = File.join(Rails.root,
                                  'spec/fixtures/course/programming_single_test_suite_report.xml')
    self::REPORT_XML = File.read(self::REPORT_PATH)

    let(:parsed_report) do
      Course::Assessment::ProgrammingTestCaseReport.new(self.class::REPORT_XML)
    end
    subject { parsed_report }

    describe '#test_suites' do
      it 'returns all the test suites in the report' do
        expect(subject.test_suites.length).to eq(1)
      end
    end

    describe '#test_cases' do
      it 'returns all the test cases in the report' do
        expect(subject.test_cases.length).to eq(3)
      end
    end

    describe Course::Assessment::ProgrammingTestCaseReport::TestCase do
      let(:test_cases) { parsed_report.test_suites.first.test_cases }

      context 'when the test case errored' do
        subject { test_cases.first }
        it { is_expected.to be_errored }
        it { is_expected.not_to be_passed }
      end
    end
  end

  context 'when given a report with test case meta information' do
    let(:report_path) do
      File.join(Rails.root, 'spec/fixtures/course/'\
                'programming_single_test_suite_report_meta.xml')
    end

    let(:report_xml) { File.read(report_path) }

    let(:parsed_report) do
      Course::Assessment::ProgrammingTestCaseReport.new(report_xml)
    end
    let(:test_cases) { parsed_report.test_suites.first.test_cases }

    describe Course::Assessment::ProgrammingTestCaseReport::TestCase do
      subject { test_cases.first }

      describe '#expression' do
        it 'returns the expression attribute' do
          expect(subject.expression).to eq('mosaic(rcross_bb, sail_bb, corner_bb, nova_bb)')
        end
      end

      describe '#expected' do
        it 'returns the expected attribute' do
          expect(subject.expected).to eq('solution_rune')
        end
      end
      describe '#hint' do
        it 'returns the hint attribute' do
          expect(subject.hint).to eq('Is there a rune?')
        end
      end
    end

    describe 'when there is no meta information' do
      subject { test_cases.second }

      describe '#expression' do
        it 'returns an empty string as the expression attribute' do
          expect(subject.expression).to eq('')
        end
      end

      describe '#expected' do
        it 'returns an empty string as the expected attribute' do
          expect(subject.expected).to eq('')
        end
      end

      describe '#hint' do
        it 'returns an empty string as the hint attribute' do
          expect(subject.hint).to eq('')
        end
      end
    end
  end

  context 'when given a report with test cases with errors' do
    let(:report_path) do
      File.join(Rails.root, 'spec/fixtures/course/'\
                'programming_single_test_suite_report.xml')
    end

    let(:report_xml) { File.read(report_path) }

    let(:parsed_report) do
      Course::Assessment::ProgrammingTestCaseReport.new(report_xml)
    end
    let(:test_cases) { parsed_report.test_suites.first.test_cases }

    describe Course::Assessment::ProgrammingTestCaseReport::TestCase do
      subject { test_cases.first }

      describe '#error_type' do
        it 'returns the error type attribute' do
          expect(subject.error_type).to eq('TypeError')
        end
      end

      describe '#error_message' do
        it 'returns the error type and error message together' do
          expect(subject.error_message).to eq('TypeError: mosaic() takes 1 positional argument but 4 were given')
        end
      end
    end

    describe 'when the test case has no error' do
      subject { test_cases.third }

      describe '#error_type' do
        it 'returns nil for the error type attribute' do
          expect(subject.error_type).to be_nil
        end

        it 'returns nil for the error message' do
          expect(subject.error_message).to be_nil
        end
      end
    end
  end
end

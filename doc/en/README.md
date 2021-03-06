# ttap: a testing framework with file system hierarchy

[![Build Status](https://travis-ci.org/fjkz/ttap.svg?branch=master)](https://travis-ci.org/fjkz/ttap)

*ttap* is a directory structure framework of test scripts. It defines the directory structure of your executable test script files and executes the scripts with the file system hierarchy.

## Usage

### Running Tests

Suppose that we have test scripts below. We later describe a set of test scripts run by ttap as a test suite.

```
test-simple
├── test_not_ok.sh
└── test_ok.sh
```

We can run them by invoking `ttap` with the root path of the test suite. If all test scripts succeed, `ttap` exits with a 0 status code. If there are any failures, `ttap` exits with a 1 status code.

The result is printed on the console.

```
$ ttap sample/test-simple
✗ test_not_ok.sh
✓ test_ok.sh

cases            : 2
succeeded        : 1
failed           : 1
time taken [sec] : 0

FAILURE

- test_not_ok.sh
```

The result is printed with [TAP (Test Anything Protocol)](http://testanything.org/) if `--format tap` option is set.

```
$ ttap sample/test-simple --format tap
not ok 1 test_not_ok.sh
ok 2 test_ok.sh
1..2
```

xUnit-like formatted output is also available with `--format xunit` option.

```
$ ttap sample/test-simple --format xunit
F.

Failures:
 - test_not_ok.sh

2 cases, 1 failures
```

The result is also output to the directory specified with `-o` option. `result.txt` is the [TAP (Test Anything Protocol)](http://testanything.org/)-formatted result. `*.out` are the standard out and the standard error of each script.

```
$ ttap sample/test-simple -format silent -o result
$ ls result
result.txt  test_not_ok.sh.out  test_ok.sh.out
```

### Writing Scripts

Any programming languages are available for writing scripts. Each script needs to satisfy the following conditions.

Script files must be executable in Unix. That is, they must have readable and executable permission. Non-executable scripts fail. And do not forget the shebang (the header starting with `#!`).

Test scripts must exit with a non-zero status code when it fails. `ttap` verifies whether each script succeeded or failed with the status code.

Note that each script is executed in the directory where it exists. `ttap` changes the working directory internally when it runs a script. If you do not want to change the working directory, you can set `--no-change-dir` option.

The following environment variables are assigned when scripts are run.

- `TTAP_EXEC_DIR` has the working directory path where `ttap` is executed.
- `TTAP_ROOT_DIR` has the root directory path of the test suite.
- `TTAP_OUTPUT_DIR` has the directory path where the test result will be put.

Multiple test cases can be written in a file if the output of the scripts is formatted with TAP. For example, [Bats](https://github.com/sstephenson/bats) can be used. Scripts which file names end with `.bats` or `.t` are expected to output TAP-formatted results. These suffixes can be changed with `--tap-regex` option.

### Directory Structure

We describe the naming rule and the directory structure that test suites must satisfy.

Files and directories in a test suite are called *nodes*. Six node types are defined:

- test-nodes,
- run-nodes,
- before-nodes,
- after-nodes,
- init-nodes,
- final-nodes.

Node types are classified with file names. File names of each node type start with respectively `test`, `run`, `before`, `after`, `init` and `final`. These prefixes can be configured with the following command line options: `--test-regex`, `--run-regex`, `--before-regex`, `--after-regex`, `--init-regex` and `--final-regex`.

Each node can have child nodes as directory entries. When a node is executed, the child nodes are executed recursively.

#### Test-Nodes

Test-nodes are main test cases.

Test-nodes have no order. Each test case should be independent. See the section of "Improvement of Test Suites".

#### Run-Nodes

Run-nodes are used as children of other node types. Before, after, init and final nodes can not have other type nodes than run-nodes.

Additionally, run-nodes and other type nodes must not be included in the same directory.

Run-nodes in a directory have a sequence unlike test-nodes. They are run by the ascending order.

#### Before-Nodes / After-Nodes

Before-nodes (after-nodes) are preconditioning (postconditioning) scripts. They run before (after) each test-node like `@Before` (`@After`) in JUnit4.

Before-nodes are run as the ascending order, and after-nodes are run as the descending order.

The following is an example.

```
$ ttap --tree sample/test-before-after
test-before-after
├── before1.sh
├── before2.sh
├── test1.sh
├── test2.sh
├── after2.sh
└── after1.sh
$ ttap --format tap sample/test-before-after
ok 1 before1.sh.1
ok 2 before2.sh.1
ok 3 test1.sh
ok 4 after2.sh.1
ok 5 after1.sh.1
ok 6 before1.sh.2
ok 7 before2.sh.2
ok 8 test2.sh
ok 9 after2.sh.2
ok 10 after1.sh.2
1..10
```

Note that when a preconditioning operation fails the following tests are skipped.

#### Init-Nodes / Final-Nodes

Init-nodes (final-nodes) are run once before (after) all tests in the same directory. They are equivalents of `@BeforeClass` (`@AfterClass`) in JUnit4.

Like before-nodes and after-nodes, init-nodes are run as the ascending order and final-nodes are run as the descending order.

The following is an example.

```
$ ttap --tree sample/test-init-final
test-init-final
├── init1.sh
├── init2.sh
├── test1.sh
├── test2.sh
├── final2.sh
└── final1.sh
$ ttap --format tap sample/test-init-final
ok 1 init1.sh
ok 2 init2.sh
ok 3 test1.sh
ok 4 test2.sh
ok 5 final2.sh
ok 6 final1.sh
1..6
```

## Testing of Test Suites

The following command line options are available for testing of test suites.

- `--tree` option prints the file system hierarchy of the test suites.
- `--print-log` option prints output of running scripts on the console.
- `--stop-on-failure` option skips remaining operations if an operation fails. The postconditioning is also skipped then.
- `--skip-all` option skips all operations. We can know the execution plan.
- `--skip` option skips specified scripts. We can also specify directory names.
- `--only` option runs only specified scripts. We can also specify directory names. Note that preconditioning and postconditioning operations are not automatically executed.

## Improvement of Test Suites

Each test should be independent. In order to force tests to be independent, `ttap` randomizes the order of running tests with `--randomize` option. `ttap` shuffles the order of tests in the same directory. The random seed is printed at the summary message. We can assign a random seed with `--randomize` option for repeatability.

Preconditioning operations should be idempotent. We can check idempotency with `--multiply-preconditioning` option. This option runs preconditioning operations twice in a row. Note that postconditioning operations do not need to be idempotent because they should expect preconditions are satisfied.

## Installation

Check out a copy of the ttap repository. Then add the ttap `bin` directory to your `PATH` environment variable.

## Requirement

- Linux
- Python 2.7 or 3.5+

## License

This work is released under the MIT License, see `LICENSE` for details.

Feature: [PIT-GR] Point in Time With Ghost Rcords

@fixture.pit
@fixture.enable_ghost_records
  Scenario: [PIT-GR-01] Load into a pit table where the AS OF table is already established with increments of a day
    Given the PIT_CUSTOMER table does not exist
    And the raw vault contains empty tables
      | HUB          | SAT                  | PIT          |
      | HUB_CUSTOMER | SAT_CUSTOMER_DETAILS | PIT_CUSTOMER |
      |              | SAT_CUSTOMER_LOGIN   |              |
      |              | SAT_CUSTOMER_PROFILE |              |
    And the RAW_STAGE_DETAILS table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS         | CUSTOMER_DOB | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>        | <null>                   | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM |
      | 1001        | Alice         | 1 Forrest road Hampshire | 1997-04-24   | 2018-06-01 00:00:00.000000 | *               |
      | 1002        | Bob           | 2 Forrest road Hampshire | 2006-04-17   | 2018-06-01 00:00:00.000000 | *               |
      | 1002        | Bob           | 3 Forrest road Hampshire | 2006-04-17   | 2018-12-01 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_DETAILS data
    And the RAW_STAGE_LOGIN table contains data
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>                     | <null>      | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM |
      | 1001        | 2019-01-01 02:00:00.000000 | Phone       | 2019-01-02 00:00:00.000000 | *               |
      | 1001        | 2019-01-02 03:00:00.000000 | Phone       | 2019-01-03 00:00:00.000000 | *               |
      | 1001        | 2019-01-03 01:00:00.000000 | Laptop      | 2019-01-04 00:00:00.000000 | *               |
      | 1002        | 2019-01-01 05:00:00.000000 | Tablet      | 2019-01-02 00:00:00.000000 | *               |
      | 1002        | 2019-01-02 06:00:00.000000 | Tablet      | 2019-01-03 00:00:00.000000 | *               |
      | 1002        | 2019-01-03 08:00:00.000000 | Tablet      | 2019-01-04 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_LOGIN data
    And the RAW_STAGE_PROFILE table contains data
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>           | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM |
      | 1001        | red              | ab12         | 2019-01-02 00:00:00.000000 | *               |
      | 1001        | blue             | ab12         | 2019-01-03 00:00:00.000000 | *               |
      | 1001        | brown            | ab12         | 2019-01-04 00:00:00.000000 | *               |
      | 1002        | yellow           | cd34         | 2019-01-02 00:00:00.000000 | *               |
      | 1002        | yellow           | ef56         | 2019-01-03 00:00:00.000000 | *               |
      | 1002        | pink             | ef56         | 2019-01-04 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2019-01-02 00:00:00.000000 |
      | 2019-01-03 00:00:00.000000 |
      | 2019-01-04 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK                      | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK          | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK            | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK          | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1002')                      | 2019-01-02 00:00:00.000000 | md5('1002')                      | 2018-12-01 00:00:00.000000 | md5('1002')                      | 2019-01-02 00:00:00.000000 | md5('1002')                      | 2019-01-02 00:00:00.000000 |
      | md5('1002')                      | 2019-01-03 00:00:00.000000 | md5('1002')                      | 2018-12-01 00:00:00.000000 | md5('1002')                      | 2019-01-03 00:00:00.000000 | md5('1002')                      | 2019-01-03 00:00:00.000000 |
      | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2018-12-01 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 |
      | md5('1001')                      | 2019-01-02 00:00:00.000000 | md5('1001')                      | 2018-06-01 00:00:00.000000 | md5('1001')                      | 2019-01-02 00:00:00.000000 | md5('1001')                      | 2019-01-02 00:00:00.000000 |
      | md5('1001')                      | 2019-01-03 00:00:00.000000 | md5('1001')                      | 2018-06-01 00:00:00.000000 | md5('1001')                      | 2019-01-03 00:00:00.000000 | md5('1001')                      | 2019-01-03 00:00:00.000000 |
      | md5('1001')                      | 2019-01-04 00:00:00.000000 | md5('1001')                      | 2018-06-01 00:00:00.000000 | md5('1001')                      | 2019-01-04 00:00:00.000000 | md5('1001')                      | 2019-01-04 00:00:00.000000 |

  @not_bigquery
  @fixture.pit
  @fixture.enable_ghost_records
  Scenario: [PIT-GR-02] Load into a pit table where the AS OF table is already established but the final pit table will deal with NULL Values as ghosts
    Given the PIT_CUSTOMER table does not exist
    And the raw vault contains empty tables
      | HUB          | SAT                  | PIT          |
      | HUB_CUSTOMER | SAT_CUSTOMER_DETAILS | PIT_CUSTOMER |
      |              | SAT_CUSTOMER_LOGIN   |              |
      |              | SAT_CUSTOMER_PROFILE |              |
    And the RAW_STAGE_DETAILS table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS         | CUSTOMER_DOB | LOAD_DATE                  | SOURCE          | CUSTOMER_PK                     |
      | <null>      | <null>        | <null>                   | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM | 0000000000000000000000000000000 |
      | 1001        | Alice         | 1 Forrest road Hampshire | 1997-04-24   | 2018-06-01 00:00:00.000000 | *               | md5('1001')                     |
      | 1002        | Bob           | 2 Forrest road Hampshire | 2006-04-17   | 2018-06-01 00:00:00.000000 | *               | md5('1002')                     |
      | 1002        | Bob           | 3 Forrest road Hampshire | 2006-04-17   | 2018-12-01 00:00:00.000000 | *               | md5('1002')                     |
    And I stage the STG_CUSTOMER_DETAILS data
    And the RAW_STAGE_LOGIN table contains data
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE          | CUSTOMER_PK                      |
      | <null>      | <null>                     | <null>      | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM | 00000000000000000000000000000000 |
      | 1001        | 2019-01-01 02:00:00.000000 | Phone       | 2019-01-02 00:00:00.000000 | *               | md5('1001')                      |
      | 1001        | 2019-01-02 03:00:00.000000 | Phone       | 2019-01-03 00:00:00.000000 | *               | md5('1001')                      |
      | 1001        | 2019-01-03 01:00:00.000000 | Laptop      | 2019-01-04 00:00:00.000000 | *               | md5('1001')                      |
      | 1002        | 2019-01-03 08:00:00.000000 | Tablet      | 2019-01-04 00:00:00.000000 | *               | md5('1002')                      |
    And I stage the STG_CUSTOMER_LOGIN data
    And the RAW_STAGE_PROFILE table contains data
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE          | CUSTOMER_PK                      |
      | <null>      | <null>           | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM | 00000000000000000000000000000000 |
      | 1001        | red              | ab12         | 2019-01-02 00:00:00.000000 | *               | md5('1001')                      |
      | 1001        | blue             | ab12         | 2019-01-03 00:00:00.000000 | *               | md5('1001')                      |
      | 1001        | brown            | ab12         | 2019-01-04 00:00:00.000000 | *               | md5('1001')                      |
      | 1002        | yellow           | cd34         | 2019-01-02 00:00:00.000000 | *               | md5('1002')                      |
      | 1002        | yellow           | ef56         | 2019-01-03 00:00:00.000000 | *               | md5('1002')                      |
      | 1002        | pink             | ef56         | 2019-01-04 00:00:00.000000 | *               | md5('1002')                      |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2019-01-02 00:00:00.000000 |
      | 2019-01-03 00:00:00.000000 |
      | 2019-01-04 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK                | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1001') | 2019-01-02 00:00:00.000000 | md5('1001')             | 2018-06-01 00:00:00.000000 | md5('1001')                          | 2019-01-02 00:00:00.000000 | md5('1001')             | 2019-01-02 00:00:00.000000 |
      | md5('1001') | 2019-01-03 00:00:00.000000 | md5('1001')             | 2018-06-01 00:00:00.000000 | md5('1001')                          | 2019-01-03 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 |
      | md5('1001') | 2019-01-04 00:00:00.000000 | md5('1001')             | 2018-06-01 00:00:00.000000 | md5('1001')                          | 2019-01-04 00:00:00.000000 | md5('1001')             | 2019-01-04 00:00:00.000000 |
      | md5('1002') | 2019-01-02 00:00:00.000000 | md5('1002')             | 2018-12-01 00:00:00.000000 | 00000000000000000000000000000000     | 1900-01-01 00:00:00.000000 | md5('1002')             | 2019-01-02 00:00:00.000000 |
      | md5('1002') | 2019-01-03 00:00:00.000000 | md5('1002')             | 2018-12-01 00:00:00.000000 | 00000000000000000000000000000000     | 1900-01-01 00:00:00.000000 | md5('1002')             | 2019-01-03 00:00:00.000000 |
      | md5('1002') | 2019-01-04 00:00:00.000000 | md5('1002')             | 2018-12-01 00:00:00.000000 | md5('1002')                          | 2019-01-04 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 |

  @not_bigquery
  @fixture.pit
    @fixture.enable_ghost_records
  Scenario: [PIT-GR-03] Load into a pit table where the AS OF table dates are before the satellites have received any entries
    Given the PIT_CUSTOMER table does not exist
    Given the raw vault contains empty tables
      | HUB          | SAT                  | PIT          |
      | HUB_CUSTOMER | SAT_CUSTOMER_DETAILS | PIT_CUSTOMER |
      |              | SAT_CUSTOMER_LOGIN   |              |
      |              | SAT_CUSTOMER_PROFILE |              |
    And the RAW_STAGE_DETAILS table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS         | CUSTOMER_DOB | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 1 Forrest road Hampshire | 1997-04-24   | 2018-06-01 00:00:00.000000 | *      |
      | 1002        | Bob           | 2 Forrest road Hampshire | 2006-04-17   | 2018-06-01 00:00:00.000000 | *      |
      | 1002        | Bob           | 3 Forrest road Hampshire | 2006-04-17   | 2018-12-01 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_DETAILS data
    And the RAW_STAGE_LOGIN table contains data
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE |
      | 1001        | 2019-01-01 02:00:00.000000 | Phone       | 2019-01-02 00:00:00.000000 | *      |
      | 1001        | 2019-01-02 03:00:00.000000 | Phone       | 2019-01-03 00:00:00.000000 | *      |
      | 1001        | 2019-01-03 01:00:00.000000 | Laptop      | 2019-01-04 00:00:00.000000 | *      |
      | 1002        | 2019-01-01 05:00:00.000000 | Tablet      | 2019-01-02 00:00:00.000000 | *      |
      | 1002        | 2019-01-02 06:00:00.000000 | Tablet      | 2019-01-03 00:00:00.000000 | *      |
      | 1002        | 2019-01-03 08:00:00.000000 | Tablet      | 2019-01-04 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_LOGIN data
    And the RAW_STAGE_PROFILE table contains data
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE |
      | 1001        | red              | ab12         | 2019-01-02 00:00:00.000000 | *      |
      | 1001        | blue             | ab12         | 2019-01-03 00:00:00.000000 | *      |
      | 1001        | brown            | ab12         | 2019-01-04 00:00:00.000000 | *      |
      | 1002        | yellow           | cd34         | 2019-01-02 00:00:00.000000 | *      |
      | 1002        | yellow           | ef56         | 2019-01-03 00:00:00.000000 | *      |
      | 1002        | pink             | ef56         | 2019-01-04 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2017-01-02 00:00:00.000000 |
      | 2017-01-03 00:00:00.000000 |
      | 2017-01-04 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK          | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK            | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK          | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1001') | 2017-01-02 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1001') | 2017-01-03 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1001') | 2017-01-04 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1002') | 2017-01-02 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1002') | 2017-01-03 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1002') | 2017-01-04 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |

  @not_bigquery
  @fixture.pit
  @fixture.enable_ghost_records
  Scenario: [PIT-06] Load into a pit table over several cycles where new record is introduced on the 3rd day
    Given the raw vault contains empty tables
      | HUB          | SAT                  | PIT          |
      | HUB_CUSTOMER | SAT_CUSTOMER_DETAILS | PIT_CUSTOMER |
      |              | SAT_CUSTOMER_LOGIN   |              |
      |              | SAT_CUSTOMER_PROFILE |              |
    And the RAW_STAGE_DETAILS is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS         | CUSTOMER_DOB | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>        | <null>                   | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM |
      | 1001        | Alice         | 1 Forrest road Hampshire | 1997-04-24   | 2019-01-03 00:00:00.000000 | *               |
      | 1001        | Alice         | 5 Forrest road Hampshire | 1997-04-24   | 2019-01-01 00:00:00.000000 | *               |
      | 1002        | Bob           | 2 Forrest road Hampshire | 2006-04-17   | 2019-01-01 00:00:00.000000 | *               |
      | 1002        | Bob           | 3 Forrest road Hampshire | 2006-04-17   | 2019-01-04 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_DETAILS data
    When the RAW_STAGE_LOGIN is loaded
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>                     | <null>      |1900-01-01 00:00:00.000000  | DBTVAULT_SYSTEM |
      | 1001        | 2019-01-01 02:00:00.000000 | Phone       | 2019-01-02 00:00:00.000000 | *               |
      | 1001        | 2019-01-02 03:00:00.000000 | Phone       | 2019-01-03 00:00:00.000000 | *               |
      | 1001        | 2019-01-03 01:00:00.000000 | Laptop      | 2019-01-04 00:00:00.000000 | *               |
      | 1002        | 2019-01-01 05:00:00.000000 | Tablet      | 2019-01-02 00:00:00.000000 | *               |
      | 1002        | 2019-01-02 06:00:00.000000 | Tablet      | 2019-01-03 00:00:00.000000 | *               |
      | 1002        | 2019-01-03 08:00:00.000000 | Tablet      | 2019-01-04 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_LOGIN data
    When the RAW_STAGE_PROFILE is loaded
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE          |
      | <null>      | <null>           | <null>       | 1900-01-01 00:00:00.000000 | DBTVAULT_SYSTEM |
      | 1001        | red              | ab12         | 2019-01-02 00:00:00.000000 | *               |
      | 1001        | blue             | ab12         | 2019-01-03 00:00:00.000000 | *               |
      | 1001        | brown            | ab12         | 2019-01-04 00:00:00.000000 | *               |
      | 1002        | yellow           | cd34         | 2019-01-02 00:00:00.000000 | *               |
      | 1002        | yellow           | ef56         | 2019-01-03 00:00:00.000000 | *               |
      | 1002        | pink             | ef56         | 2019-01-04 00:00:00.000000 | *               |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2019-01-02 00:00:00.000000 |
      | 2019-01-03 00:00:00.000000 |
      | 2019-01-04 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1001') | 2019-01-02 00:00:00.000000 | md5('1001')             | 2019-01-01 00:00:00.000000 | md5('1001')           | 2019-01-02 00:00:00.000000 | md5('1001')             | 2019-01-02 00:00:00.000000 |
      | md5('1001') | 2019-01-03 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 | md5('1001')           | 2019-01-03 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 |
      | md5('1001') | 2019-01-04 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 | md5('1001')           | 2019-01-04 00:00:00.000000 | md5('1001')             | 2019-01-04 00:00:00.000000 |
      | md5('1002') | 2019-01-02 00:00:00.000000 | md5('1002')             | 2019-01-01 00:00:00.000000 | md5('1002')           | 2019-01-02 00:00:00.000000 | md5('1002')             | 2019-01-02 00:00:00.000000 |
      | md5('1002') | 2019-01-03 00:00:00.000000 | md5('1002')             | 2019-01-01 00:00:00.000000 | md5('1002')           | 2019-01-03 00:00:00.000000 | md5('1002')             | 2019-01-03 00:00:00.000000 |
      | md5('1002') | 2019-01-04 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 | md5('1002')           | 2019-01-04 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 |
    When the RAW_STAGE_LOGIN is loaded
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE |
      | 1001        | 2019-01-04 06:00:00.000000 | Tablet      | 2019-01-05 00:00:00.000000 | *      |
      | 1002        | 2019-01-04 04:00:00.000000 | Laptop      | 2019-01-05 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_LOGIN data
    When the RAW_STAGE_PROFILE is loaded
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE |
      | 1001        | black            | ab12         | 2019-01-05 00:00:00.000000 | *      |
      | 1002        | red              | ef56         | 2019-01-05 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2019-01-03 00:00:00.000000 |
      | 2019-01-04 00:00:00.000000 |
      | 2019-01-05 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1001') | 2019-01-03 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 | md5('1001')           | 2019-01-03 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 |
      | md5('1001') | 2019-01-04 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 | md5('1001')           | 2019-01-04 00:00:00.000000 | md5('1001')             | 2019-01-04 00:00:00.000000 |
      | md5('1001') | 2019-01-05 00:00:00.000000 | md5('1001')             | 2019-01-03 00:00:00.000000 | md5('1001')           | 2019-01-05 00:00:00.000000 | md5('1001')             | 2019-01-05 00:00:00.000000 |
      | md5('1002') | 2019-01-03 00:00:00.000000 | md5('1002')             | 2019-01-01 00:00:00.000000 | md5('1002')           | 2019-01-03 00:00:00.000000 | md5('1002')             | 2019-01-03 00:00:00.000000 |
      | md5('1002') | 2019-01-04 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 | md5('1002')           | 2019-01-04 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 |
      | md5('1002') | 2019-01-05 00:00:00.000000 | md5('1002')             | 2019-01-04 00:00:00.000000 | md5('1002')           | 2019-01-05 00:00:00.000000 | md5('1002')             | 2019-01-05 00:00:00.000000 |
    When the RAW_STAGE_DETAILS is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS         | CUSTOMER_DOB | LOAD_DATE                  | SOURCE |
      | 1003        | Chad          | 4 Forrest road Hampshire | 1998-01-16   | 2019-01-06 00:00:00.000000 | *      |
    When the RAW_STAGE_LOGIN is loaded
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE |
      | 1001        | 2019-01-05 06:00:00.000000 | Tablet      | 2019-01-06 00:00:00.000000 | *      |
      | 1002        | 2019-01-05 04:00:00.000000 | Laptop      | 2019-01-06 00:00:00.000000 | *      |
      | 1003        | 2019-01-05 03:00:00.000000 | Laptop      | 2019-01-06 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_LOGIN data
    When the RAW_STAGE_PROFILE is loaded
      | CUSTOMER_ID | DASHBOARD_COLOUR | DISPLAY_NAME | LOAD_DATE                  | SOURCE |
      | 1001        | yellow           | ab12         | 2019-01-06 00:00:00.000000 | *      |
      | 1002        | purple           | ef56         | 2019-01-06 00:00:00.000000 | *      |
      | 1003        | black            | gh78         | 2019-01-06 00:00:00.000000 | *      |
    And I stage the STG_CUSTOMER_PROFILE data
    And the AS_OF_DATE table is created and populated with data
      | AS_OF_DATE                 |
      | 2019-01-04 00:00:00.000000 |
      | 2019-01-05 00:00:00.000000 |
      | 2019-01-06 00:00:00.000000 |
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_PK          | SAT_CUSTOMER_DETAILS_LDTS  | SAT_CUSTOMER_LOGIN_PK            | SAT_CUSTOMER_LOGIN_LDTS    | SAT_CUSTOMER_PROFILE_PK          | SAT_CUSTOMER_PROFILE_LDTS  |
      | md5('1001') | 2019-01-04 00:00:00.000000 | md5('1001')                      | 2019-01-03 00:00:00.000000 | md5('1001')                      | 2019-01-04 00:00:00.000000 | md5('1001')                      | 2019-01-04 00:00:00.000000 |
      | md5('1001') | 2019-01-05 00:00:00.000000 | md5('1001')                      | 2019-01-03 00:00:00.000000 | md5('1001')                      | 2019-01-05 00:00:00.000000 | md5('1001')                      | 2019-01-05 00:00:00.000000 |
      | md5('1001') | 2019-01-06 00:00:00.000000 | md5('1001')                      | 2019-01-03 00:00:00.000000 | md5('1001')                      | 2019-01-06 00:00:00.000000 | md5('1001')                      | 2019-01-06 00:00:00.000000 |
      | md5('1002') | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 |
      | md5('1002') | 2019-01-05 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-05 00:00:00.000000 | md5('1002')                      | 2019-01-05 00:00:00.000000 |
      | md5('1002') | 2019-01-06 00:00:00.000000 | md5('1002')                      | 2019-01-04 00:00:00.000000 | md5('1002')                      | 2019-01-06 00:00:00.000000 | md5('1002')                      | 2019-01-06 00:00:00.000000 |
      | md5('1003') | 2019-01-04 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1003') | 2019-01-05 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 | 00000000000000000000000000000000 | 1900-01-01 00:00:00.000000 |
      | md5('1003') | 2019-01-06 00:00:00.000000 | md5('1003')                      | 2019-01-06 00:00:00.000000 | md5('1003')                      | 2019-01-06 00:00:00.000000 | md5('1003')                      | 2019-01-06 00:00:00.000000 |
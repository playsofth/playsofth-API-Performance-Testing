*** Settings ***
Library         RequestsLibrary
Library         Collections
#Library         BuiltIn

*** Variables ***
${BASE_URL}     https://jsonplaceholder.typicode.com
# Performance Test Variables
${NUM_REQUESTS}         5
${MAX_AVG_TIME_MS}      500

*** Test Cases ***
API Performance Testing with Percentiles and Standard Deviation
    [Documentation]     A simple performance test to measure the average response time of API endpoints.
    [Tags]              apitest      performance
    [Teardown]          Delete All Sessions
    Create Session      jsonplaceholder_session     ${BASE_URL}    verify=True
    Measure Endpoint Performance        jsonplaceholder_session     /users      ${NUM_REQUESTS}     ${MAX_AVG_TIME_MS}
    Measure Endpoint Performance        jsonplaceholder_session     /posts      ${NUM_REQUESTS}     ${MAX_AVG_TIME_MS}
    Measure Endpoint Performance        jsonplaceholder_session     /comments     ${NUM_REQUESTS}     ${MAX_AVG_TIME_MS}

*** Keywords ***
Measure Endpoint Performance
    [Arguments]     ${session}      ${endpoint}     ${num_requests}     ${max_avg_time_ms}
    Log To Console      \n--- Measuring performance for endpoint: ${endpoint} ---
    @{response_times_ms}=       Create List
    FOR     ${i}        IN RANGE        ${num_requests}
        ${resp}=    GET On Session    ${session}    ${endpoint}    expected_status=200
        ${response_time_ms}=        Evaluate        $resp.elapsed.total_seconds() * 1000
        Should Be True    ${response_time_ms} < ${max_avg_time_ms}    msg=API is slow!
        Append To List      ${response_times_ms}      ${response_time_ms}
        Log     Request ${i+1}/${num_requests} to ${endpoint} took ${response_time_ms} ms.
    END
    # Statisztikák kiszámítása
    ${avg_time_ms}=    Evaluate    statistics.mean($response_times_ms)    modules=statistics
    ${max_time_ms}=    Evaluate    max($response_times_ms)
    ${stdev_ms}=       Evaluate    statistics.stdev($response_times_ms) if len($response_times_ms) > 1 else 0    modules=statistics
    ${f_avg}=          Evaluate    "{:.2f}".format($avg_time_ms)
    ${f_max}=          Evaluate    "{:.2f}".format($max_time_ms)
    ${f_std}=          Evaluate    "{:.2f}".format($stdev_ms)
    ${avg_time_ms}=         Evaluate        sum($response_times_ms) / len($response_times_ms)
    # Format the average time here before logging
    ${formatted_avg_time}=      Evaluate        "{:.2f}".format($avg_time_ms)
    Log To Console     Average: ${f_avg} ms | Max: ${f_max} ms | StdDev: ${f_std} ms
    Should Be True      ${avg_time_ms} < ${max_avg_time_ms}       msg=Average response time for ${endpoint} (${f_avg} ms) exceeded the limit of ${max_avg_time_ms} ms.
    
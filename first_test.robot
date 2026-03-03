***Settings***
Library    RequestsLibrary
Library    Collections

***Variables***
${BASE_URL}         https://jsonplaceholder.typicode.com
${HEADERS}          Content-Type=application/json

***Test Cases***
Get All Posts
    [Documentation]    Tests fetching all posts from the API.
    Create Session    jsonplaceholder    ${BASE_URL}    verify=True
    ${resp}=          Get Request    jsonplaceholder    /posts
    Should Be Equal As Integers    ${resp.status_code}    200
    Log To Console    Response Status: ${resp.status_code}
    Log To Console    Response Body (first 200 chars): ${resp.text[:200]}
    # Verify that the response is a list and contains items
    ${json_body}=     To Json    ${resp.text}
    Should Be True    isinstance(${json_body}, list)
    Should Not Be Empty    ${json_body}
    # Verify a specific field in the first item (optional, for more detailed testing)
    # Get Length    ${json_body}    >= 1
    # Dictionary Should Contain Key    ${json_body}[0]    title

Get Single Post
    [Documentation]    Tests fetching a single post by ID.
    Create Session    jsonplaceholder    ${BASE_URL}    verify=True
    ${resp}=          Get Request    jsonplaceholder    /posts/1
    Should Be Equal As Integers    ${resp.status_code}    200
    Log To Console    Response Status: ${resp.status_code}
    Log To Console    Response Body: ${resp.text}
    ${json_body}=     To Json    ${resp.text}
    Dictionary Should Contain Key    ${json_body}    id
    Should Be Equal As Integers    ${json_body}[id]    1
    Dictionary Should Contain Key    ${json_body}    title
    Dictionary Should Contain Key    ${json_body}    body
    Dictionary Should Contain Key    ${json_body}    userId
    Should Not Be Empty    ${json_body}[title]
    Should Not Be Empty    ${json_body}[body]

Create New Post
    [Documentation]    Tests creating a new post via POST request.
    ${payload}=       Create Dictionary    title=foo    body=bar    userId=1
    Create Session    jsonplaceholder    ${BASE_URL}    verify=True
    ${resp}=          Post Request    jsonplaceholder    /posts    json=${payload}    headers=${HEADERS}
    Should Be Equal As Integers    ${resp.status_code}    201
    Log To Console    Response Status: ${resp.status_code}
    Log To Console    Response Body: ${resp.text}
    ${json_body}=     To Json    ${resp.text}
    Dictionary Should Contain Key    ${json_body}    id
    Should Be Greater Than    ${json_body}[id]    0    # New ID should be generated
    Should Be Equal    ${json_body}[title]    foo
    Should Be Equal    ${json_body}[body]     bar
    Should Be Equal As Integers    ${json_body}[userId]    1
    
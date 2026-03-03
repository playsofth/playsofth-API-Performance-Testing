*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    DiffLibrary

*** Variables ***
${BASE_URL}          https://jsonplaceholder.typicode.com
${OUTPUT_FILE}       test_output.txt
${REFERENCE_FILE}    reference.txt

*** Test Cases ***
API Adatgyujtes Es Osszehasonlitas
    [Documentation]    Felhasználók, posztok és kommentek lekérése és mentése.
    
    # Session létrehozása
    Create Session    json_session    ${BASE_URL}    verify=True
    
    # Output fájl alaphelyzetbe állítása
    Create File       ${OUTPUT_FILE}    content=${EMPTY}
    
    # Adatok lekérése az API-ból
    ${resp_u}=        GET On Session    json_session    /users
    ${resp_p}=        GET On Session    json_session    /posts
    ${resp_c}=        GET On Session    json_session    /comments

    ${users}=         Set Variable    ${resp_u.json()}
    ${posts}=         Set Variable    ${resp_p.json()}
    ${comments}=      Set Variable    ${resp_c.json()}

    # Globális statisztikák írása
    ${u_count}=       Get Length    ${users}
    ${p_count}=       Get Length    ${posts}
    ${c_count}=       Get Length    ${comments}

    Append To File    ${OUTPUT_FILE}    --- Number of users: ${u_count}${\n}
    Append To File    ${OUTPUT_FILE}    --- Number of posts: ${p_count}${\n}
    Append To File    ${OUTPUT_FILE}    --- Number of comments: ${c_count}${\n}
    Append To File    ${OUTPUT_FILE}    --- User Details ---${\n}

    # Ciklus a felhasználókon
    FOR    ${user}    IN    @{users}
        ${u_id}=      Set Variable    ${user}[id]
        Append To File    ${OUTPUT_FILE}    --- Posts for user: ${user}[name] (ID: ${u_id}) ---${\n}
        
        # Posztok szűrése az adott felhasználóhoz (Python Evaluate segítségével)
        ${u_posts}=    Evaluate    [p for p in $posts if int(p['userId']) == int($u_id)]
        
        FOR    ${post}    IN    @{u_posts}
            ${p_id}=    Set Variable    ${post}[id]
            Append To File    ${OUTPUT_FILE}    - Post Title: ${post}[title]${\n}
            
            # Kommentek szűrése az adott poszthoz
            ${p_comments}=    Evaluate    [c for c in $comments if int(c['postId']) == int($p_id)]
            ${filtered_c_count}=    Get Length    ${p_comments}
            
            Append To File    ${OUTPUT_FILE}    - Number of comments for this post: ${filtered_c_count}${\n}
            
            FOR    ${comment}    IN    @{p_comments}
                Append To File    ${OUTPUT_FILE}    - Comment Body: ${comment}[body]${\n}
            END
        END
    END

    # Összehasonlítás a referencia fájllal
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${REFERENCE_FILE}
    IF    ${exists}
        Diff Files    ${OUTPUT_FILE}    ${REFERENCE_FILE}    fail_on_difference=False
    END
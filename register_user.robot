*** Settings ***
Suite Setup       Connect To Database    pyodbc    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
Suite Teardown    Disconnect From Database
Library    SeleniumLibrary
Library    DatabaseLibrary



*** Variables ***
${URL}    https://nightphoto-dccta3ate6ajbtb8.northeurope-01.azurewebsites.net/
${BROWSER}    Firefox
${DBname}    NightPhotoDB
${DBuser}    
${DBpass}    
${DBhost}    
${DBport}    
${APIURL}    https://nphotoapi-ascra0avhfaedzfh.northeurope-01.azurewebsites.net/api/Users/authenticate


*** Test Cases ***
Creating a new user to db with valid details
    #Form data from NightPhoto Frontend to npAPI to NightPhotoDB
    Open Browser    ${URL}    Firefox     
    Click Element    xpath=//a[text()='Register']
    Input Text    name=firstname    Test
    Input Text    name=lastname    Data
    Input Text    name=username    testdata123
    Input Text    name=email    testdata@example.com
    Input Text    name=password    testing123
    Click Button    xpath=//button[text()='Create Account']


    # Wait for the database to update
    Sleep    5s

    #Verify user in database
    ${result}=    Query    SELECT * FROM UsersTable WHERE username='testdata123'
    Should Not Be Empty    ${result}
    Log    user verified in the nightphotoDB
    [Teardown]    Close Browser


Creating a new user with empty fields
    Open Browser    ${URL}    Firefox     
    Click Element    xpath=//a[text()='Register']
    Click Button    xpath=//button[text()='Create Account']

    # Wait for the database to update
    Sleep    5s

    # checking if there is empty fields
    ${result}=    Query    SELECT * FROM UsersTable WHERE Firstname='' OR Lastname='' OR Username='' OR Email='' OR Password=''
    Should Be Empty    ${result}
    Log    No user with empty fields found in the database

Creating a new user with invalid email format
    Open Browser    ${URL}    Firefox     
    Click Element    xpath=//a[text()='Register']
    Input Text    name=firstname    Test
    Input Text    name=lastname    Data
    Input Text    name=username    invalidemailtest
    Input Text    name=email    invalidemail
    Input Text    name=password    testing123
    Click Button    xpath=//button[text()='Create Account']

     Sleep    5s

    # Verify that the user is not created in the database
    ${result}=    Query    SELECT * FROM UsersTable WHERE username='invalidemailtest'
    Should Be Empty    ${result}

Creating a new user with dublicate username
    Open Browser    ${URL}    Firefox     
    Click Element    xpath=//a[text()='Register']
    Input Text    name=firstname    Test
    Input Text    name=lastname    Data
    Input Text    name=username    duplicate
    Input Text    name=email    email@email.com
    Input Text    name=password    testing123
    Click Button    xpath=//button[text()='Create Account']

    Sleep    5s

    Open Browser    ${URL}    Firefox     
    Click Element    xpath=//a[text()='Register']
    Input Text    name=firstname    Test
    Input Text    name=lastname    Data
    Input Text    name=username    duplicate
    Input Text    name=email    email@email.com
    Input Text    name=password    testing123
    Click Button    xpath=//button[text()='Create Account']

    # Verify that the user is not created in the database
    ${result}=    Query    SELECT COUNT(*) FROM UsersTable WHERE username='duplicate'
    Should Be Equal As Numbers    ${result[0][0]}    1







######################################SIGN IN TEST CASES######################################

Sign in with valid details
    Open Browser    ${URL}    Firefox
    Click Element    xpath=//a[text()='Login']
    Input Text    name=Username    testdata123
    Input Text    name=Password    testing123
    Click Button    xpath=//button[text()='Log In']
    Wait Until Element Is Visible    xpath=//button[text()='SIGNED IN']

   


Sign in with invalid details
    Open Browser    ${URL}    Firefox
    Click Element    xpath=//a[text()='Login']
    Input Text    name=Username    invalidusername
    Input Text    name=Password    invalidpassword
    Click Button    xpath=//button[text()='Log In']
    Wait Until Element Is Not Visible    xpath=//button[text()='SIGNED IN']    timeout=5s
    [Teardown]    Close Browser
    
Signed in user can access authorized endpoint
    Open Browser    ${URL}    Firefox
    Click Element    xpath=//a[text()='Login']
    Input Text    name=Username    testdata123
    Input Text    name=Password    testing123
    Click Button    xpath=//button[text()='Log In']
    Wait Until Element Is Visible    xpath=//button[text()='SIGNED IN']

    #authorized
    Click Element    xpath=//a[text()='Upload Image']
    Wait Until Element Is Visible    xpath=//button[text()='Upload']

User cannot access authorized content before sign in
    Open Browser    ${URL}    Firefox
    Click Element    xpath=//a[text()='Upload Image']
    Wait Until Element Is Visible    xpath=//p[text()='Please log in to upload an image.']
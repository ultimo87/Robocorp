*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.Excel.Application

*** Variables ***
@{orders}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    @{orders}    Get orders
    FOR    ${element}    IN    @{orders}
        Log    ${element}
        Close the annoying modal
        Wait Until Keyword Succeeds    3x    1.5 sec    Fill the form    ${element}        
        Wait Until Keyword Succeeds    3x    1.5 sec    Download and store the receipt    ${element}
        Order another Robot
    END
    [Teardown]    Close RobotSpareBin Browser



*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    @{orders}=    Read table from CSV    orders.csv    header:${True}
    RETURN    @{orders}

Close the annoying modal
    Click Button When Visible     xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:head
    Select From List By Index    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]   ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    preview
    Click Button    order
    Wait Until Element Is Visible    id:receipt    timeout=10
    

Download and store the receipt
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:receipt    timeout=10
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}ricevute/receipt${row}[Order number].pdf
    Screenshot    id:robot-preview-image   ${OUTPUT_DIR}${/}ricevute/preview${row}[Order number].png
    Add Watermark Image To PDF
    ...             image_path=${OUTPUT_DIR}${/}ricevute/preview${row}[Order number].png
    ...             source_path=${OUTPUT_DIR}${/}ricevute/receipt${row}[Order number].pdf
    ...             output_path=${OUTPUT_DIR}${/}ricevute/complete${row}[Order number].pdf

Order another Robot
    Click Button    order-another

Close RobotSpareBin Browser
    Close Browser

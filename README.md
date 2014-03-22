Salespod2
=========

Features:

- Application gets POIs in range of 1000m from current location
- Information about objects is saved to local DB
- When you click on pin ,you can edit name and addres and save them in DB
- On refresh,data about objects is read from DB 
- If there is no connection, data is read from DB and any object that is 1000m or less from current location is shown
- By pressing "Take Photo", you can take photo of object and send it to Amazon's S3 service
- By pressing "Choose Photo" you can send photo's from Camera Roll to S3


ToDo:

- Using AR, show mark about object you are pointing at while taking photo and use that object's name as
  default value for "Photo name" input dialog (one that is shown before uploading to S3)

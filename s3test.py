import boto
import boto.s3.connection
access_key = 'JFUGTIS1MNHGP0T1T2W6'
secret_key = 'OLMwtLtZUBas239C6RZo0pNqOmto4bSAawS4N4hv'
bucketname = 'demo_bucket'
filename = 'demo_file4'
conn = boto.connect_s3(
aws_access_key_id = access_key,
aws_secret_access_key = secret_key,
host = 'cephogw1.hostconfig.mgmt.us1.dev.md.fireeye.com',
is_secure=False,
calling_format = boto.s3.connection.OrdinaryCallingFormat(),
)

def createbucket (bucketname):
  bucket = conn.create_bucket(bucketname)
  for bucket in conn.get_all_buckets():
        print "{name}\t{created}".format(
                name = bucket.name,
                created = bucket.creation_date,
)

def createfile (bucketname, filename):
  bucket = conn.get_bucket(bucketname)
  key = bucket.new_key(filename)
  key.set_contents_from_string('Hello World!')

def listfiles (bucketname):
  bucket = conn.get_bucket(bucketname)
  for file_key in bucket.list():
    print "{name}\t{size}\t{modified}".format(
                name = file_key.name,
                size = file_key.size,
                modified = file_key.last_modified,
                )

def downloadfile (bucketname, filename):
  bucket = conn.get_bucket(bucketname)
  key = bucket.get_key(filename)
  key.get_contents_to_filename('/tmp/object')

def createurl (bucketname):
  bucket = conn.get_bucket(bucketname)
  key = bucket.new_key('secret_plans.txt')
  key.set_contents_from_string('Kane Secret War Plan')
  plans_key = bucket.get_key('secret_plans.txt')
  plans_url = plans_key.generate_url(3600, query_auth=True, force_http=True)
  print plans_url

menu = {}
menu['1']="Create Bucket" 
menu['2']="Create File"
menu['3']="List Files"
menu['4']="Download File"
menu['5']="Create Url"
menu['6']="Exit"
while True: 
  options=menu.keys()
  options.sort()
  for entry in options: 
    print entry, menu[entry]
  selection=raw_input("Please Select:") 
  if selection =='1': 
    print ("Creating Bucket " + bucketname)
    createbucket(bucketname) 
  elif selection == '2': 
    print ("Creating File " + filename)
    createfile(bucketname, filename)
  elif selection == '3':
    print ("Printing a List of Files in Bucket: " + bucketname)
    listfiles(bucketname)
  elif selection == '4':
    print ("Downloading the File to /tmp/object")
    downloadfile(bucketname, filename)
  elif selection == '5':
    print ("Giving you a temp URL to Secret Plans")
    createurl(bucketname)
  elif selection == '6': 
    break
  else: 
    print "Unknown Option Selected!" 

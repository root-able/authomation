# --- coding: utf-8 ---

import datetime
import json
import os

INPUT_PATH	= '09 - Splunk Data Inputs/Données Mobile/Paul - Huawei P9/Journaux/Imported'
INPUT_DELIM	= '<;>'
INPUT_LINE_END	= '<E>'

FILE_SMS	= os.path.join(INPUT_PATH, "sms.bkp")
FILE_CONTACT	= os.path.join(INPUT_PATH, "contacts.bkp")
PHONE_DELIM	= '<>'

DATE_FORMAT	= '%Y-%m-%d %H:%M:%S.%f %z'

OUTPUT_LIST	= []
OUTPUT_FILE	= 'test.json'


local_phone	= '+33686831162'

with open(FILE_CONTACT, 'r') as contact_file :

	contact_raw	= contact_file.read()
	contact_table	= contact_raw.split(INPUT_LINE_END)

contact_dict		= {}

for contact in contact_table :

	contact_content     	= contact.split(INPUT_DELIM)

	if len(contact_content) == 31 :

		contact_name	= contact_content[1].strip()+" "+contact_content[2].strip()

		contact_phone	= contact_content[7].split(PHONE_DELIM)

		for phone_number in contact_phone :

			phone_number_clean		 = phone_number.split(';')[0]

			if not contact_dict.get(phone_number_clean) :
				contact_dict[phone_number_clean] = contact_name.strip()

			else :
				print('Found duplicate contact: '+contact)

	elif len(contact_content) > 1 :
		
		print('Ignored line: '+contact)

print(contact_dict)

with open(FILE_SMS, 'r') as msg_file :

	msg_raw		= msg_file.read()
	msg_table	= msg_raw.split(INPUT_LINE_END)

for msg in msg_table :

	msg_content	= msg.split(INPUT_DELIM)
	
	if len(msg_content) == 13 :

		msg_dict		= {}
	
		msg_dict['direction']	= 'outbound' if msg_content[6] == "2" else 'inbound'

		msg_correspondant	= msg_content[0].replace('\n', '')

		if msg_dict['direction'] == "outbound":

			msg_dict['src_phone']	= local_phone
			msg_dict['dest_phone']	= msg_correspondant

		else :
			
			msg_dict['src_phone']	= msg_correspondant
			msg_dict['dest_phone']	= local_phone

		msg_dict['time_stamp']	= float(msg_content[2][:10] + '.' + msg_content[2][10:])
		msg_dict['time_date']	= datetime.datetime.utcfromtimestamp(msg_dict['time_stamp']).strftime(DATE_FORMAT)[:-4]
		msg_dict['msg_text']	= msg_content[8]

		OUTPUT_LIST.append(msg_dict)

	elif len(msg_content) > 1 :
		
		print('Ignored line: '+msg)

with open(OUTPUT_FILE, 'w') as output_file :

	json.dump(OUTPUT_LIST, output_file, indent=4, sort_keys=True)

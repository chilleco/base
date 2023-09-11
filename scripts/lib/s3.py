"""
Functionality of S3
"""

import boto3
from botocore.exceptions import NoCredentialsError
from libdev.cfg import cfg
from libdev.gen import generate


s3 = boto3.client(
    's3',
    endpoint_url=cfg('s3.host'),
    aws_access_key_id=cfg('s3.user'),
    aws_secret_access_key=cfg('s3.pass'),
    region_name='us-east-1',
)

def upload_file(
    file,
    directory=cfg('mode'),
    bucket=cfg('project_name'),
):
    """ Upload file """

    file_type = file.split('.')[-1]
    name = f"{directory}/{generate()}.{file_type}"

    try:
        s3.upload_file(file, bucket, name)
    except FileNotFoundError:
        return None
    except NoCredentialsError:
        return None

    return f"{cfg('s3.host')}{bucket}/{name}"

def get_buckets():
    """ Get list of buckets """
    return [bucket['Name'] for bucket in s3.list_buckets()['Buckets']]


__all__ = (
    's3',
    'upload_file',
    'get_buckets',
)

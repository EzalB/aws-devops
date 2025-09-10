#!/usr/bin/env python3
"""
backup_check.py — Verify backups in S3 and CRD status.
Sends consolidated health report.
"""

import boto3
import datetime
import argparse
import json
from kubernetes import client, config

def check_s3(bucket, prefix, region):
    s3 = boto3.client("s3", region_name=region)
    response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    if "Contents" not in response:
        return {"status": "FAIL", "reason": "No backups found"}
    latest = max(response["Contents"], key=lambda x: x["LastModified"])
    age = (datetime.datetime.now(datetime.timezone.utc) - latest["LastModified"]).total_seconds() / 3600
    return {"status": "OK" if age < 24 else "WARN", "latest_backup": str(latest["LastModified"])}

def check_crd(namespace="default"):
    config.load_incluster_config()
    api = client.CustomObjectsApi()
    group = "ops.example.com"
    version = "v1alpha1"
    plural = "backupschedules"
    schedules = api.list_namespaced_custom_object(group, version, namespace, plural)
    return {"backupSchedules": schedules}

def main():
    parser = argparse.ArgumentParser(description="Backup health checker")
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--prefix", default="backups/")
    parser.add_argument("--region", default="us-east-1")
    parser.add_argument("--namespace", default="default")
    args = parser.parse_args()

    s3_status = check_s3(args.bucket, args.prefix, args.region)
    crd_status = check_crd(args.namespace)

    report = {"s3": s3_status, "crd": crd_status}
    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    main()

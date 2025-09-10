#!/usr/bin/env python3
"""
deploy_helper.py — Assist devs in creating test namespaces and cleaning resources
"""

import argparse
from kubernetes import client, config

def create_namespace(name):
    v1 = client.CoreV1Api()
    body = client.V1Namespace(metadata=client.V1ObjectMeta(name=name))
    v1.create_namespace(body=body)
    print(f"[INFO] Namespace {name} created.")

def delete_namespace(name):
    v1 = client.CoreV1Api()
    v1.delete_namespace(name)
    print(f"[INFO] Namespace {name} deleted.")

def list_namespaces():
    v1 = client.CoreV1Api()
    for ns in v1.list_namespace().items:
        print(ns.metadata.name)

def main():
    parser = argparse.ArgumentParser(description="Deploy helper for developers")
    subparsers = parser.add_subparsers(dest="command")

    ns_create = subparsers.add_parser("create")
    ns_create.add_argument("--name", required=True)

    ns_delete = subparsers.add_parser("delete")
    ns_delete.add_argument("--name", required=True)

    subparsers.add_parser("list")

    args = parser.parse_args()
    config.load_kube_config()

    if args.command == "create":
        create_namespace(args.name)
    elif args.command == "delete":
        delete_namespace(args.name)
    elif args.command == "list":
        list_namespaces()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

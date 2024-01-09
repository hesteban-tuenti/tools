import argparse
from re import findall


def get_ids(filename):
    """Get ids from the file"""
    with open(filename, "r") as file:
        ids = findall(r".*(QANOV-\d*)", file.read())
    return ids

def generate_jira_query(ids):
    """Generate JQL query"""
    query = f"issuekey in ({', '.join(ids)})"
    return query

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="The name of the file to read ids from")
    args = parser.parse_args()
    
    ids = get_ids(args.filename)
    print(generate_jira_query(ids))
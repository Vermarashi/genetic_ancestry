# Read the update FID.txt file and create dictionaries of old FID to new FID mapping for both columns
fid_mapping_col1 = {}
fid_mapping_col2 = {}
with open('update_ids.txt', 'r') as update_fid_file:
    for line in update_fid_file:
        old_fid, new_fid_col1, new_fid_col2 = line.strip().split()
        fid_mapping_col1[old_fid] = new_fid_col1
        fid_mapping_col2[old_fid] = new_fid_col2

# Read the original file and create a new content with updated FIDs
new_content = []
with open('merged.fam', 'r') as original_file:
    for line in original_file:
        columns = line.strip().split()
        old_fid = columns[0]
        new_fid_col1 = fid_mapping_col1.get(old_fid, columns[0])
        new_fid_col2 = fid_mapping_col2.get(old_fid, columns[1])
        columns[0] = new_fid_col1
        columns[1] = new_fid_col2
        new_line = ' '.join(columns) + '\n'
        new_content.append(new_line)

# Write the new content back to the original file
with open('merged.fam', 'w') as original_file:
    original_file.writelines(new_content)

print("FIDs in both columns updated successfully.")


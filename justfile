default:
    just --list

# 分割大文件到指定目录（调用Python脚本实现）
split_into_bak big_file_path:
  #!/usr/bin/env python3
  import os
  import sys

  big_file = os.path.abspath("{{big_file_path}}")
  print(f"{big_file}")

  # 检查文件是否存在
  if not os.path.exists(big_file):
      print(f"错误: 文件 '{big_file}' 不存在", file=sys.stderr)
      sys.exit(1)

  # 检查是否为文件
  if not os.path.isfile(big_file):
      print(f"错误: '{big_file}' 不是一个文件", file=sys.stderr)
      sys.exit(1)

  # 获取文件大小（用于信息输出）
  try:
      file_size = os.path.getsize(big_file)
  except OSError as e:
      print(f"错误: 无法获取文件大小: {e}", file=sys.stderr)
      sys.exit(1)

  bak_dir = "bak"
  file_dir = os.path.dirname(big_file)
  file_name = os.path.basename(big_file)
  target_dir = os.path.join(bak_dir, file_name)

  # 创建目标目录
  try:
      os.makedirs(target_dir, exist_ok=True)
  except OSError as e:
      print(f"错误: 无法创建目录 '{target_dir}': {e}", file=sys.stderr)
      sys.exit(1)

  # 分割文件（每个块10MB）
  chunk_size = 10 * 1024 * 1024  # 10MB
  part_num = 0

  try:
      with open(big_file, 'rb') as f:
          while True:
              chunk = f.read(chunk_size)
              if not chunk:
                  break
              part_num += 1
              part_file = os.path.join(target_dir, f"{file_name}.part{part_num:03d}")
              with open(part_file, 'wb') as p:
                  p.write(chunk)
  except Exception as e:
      print(f"错误: 文件分割失败: {e}", file=sys.stderr)
      sys.exit(1)

  # 输出摘要信息
  print(f"成功: 文件 '{file_name}' ({file_size:,} 字节) 已分割为{part_num}个部分")
  print(f"分割后的文件位于: {target_dir}")


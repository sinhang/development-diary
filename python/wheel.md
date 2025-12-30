### python wheel 构建
```shell
pip install wheel
python setup.py bdist_wheel
#python setup.py bdist_wheel --universal
#python setup.py bdist_wheel --universal --python-tag py2.py3
#python setup.py bdist_wheel --universal --python-tag py2.py3 --plat-name manylinux1_x86_64
```
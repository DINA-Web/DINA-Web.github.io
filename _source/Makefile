# You must have jekyll and R installed, and they must be in PATH. For R, you
# need to install the servr package.

all:
	Rscript -e "servr::jekyll('..')"

clean:
	rm -r ../_site
	rm ../_posts/*

deploy:
	scp -r ../_site/* root@dw.nrm.se:/var/www/html

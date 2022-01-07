var App = App || {};

App.tip = function (message, time) {
    time = time || 4000;
    let body = $('body');
    let obj = body.find('.toast');
    if (!obj.length) {
        obj = $('<div/>', {'class': 'toast'});
        body.append(obj);
    }
    obj.html(message);
    window.setTimeout(function () {
        obj.remove();
    }, time);
};

App.modal = function ($this, html, size, callback) {
    let modal_size = size || $this.data('modal-size') || 'sm'
    let url = $this.data('href') || $this.data('download') || $this.attr('href');
    let title = $this.data('tooltip') || $this.attr('title') || $this.text();
    let $modal = $('.modal');
    $modal.attr('class', 'active modal modal-' + modal_size)

    let $body = $modal.find('.modal-body')
    $body.html("<div class=\"loading loading-lg\"></div>")

    $modal.find('.modal-title').html(title)
    $modal.find('.buttons').html('')
    $(document).on('click', '.modal .btn-close', function () {
        $modal.removeClass('active');
        $body.html('')
    })
    if (html) {
        $body.html(html)
        return
    }
    $.ajax({
        type: 'GET',
        url: url,
        context: $this,
        dataType: 'html',
        beforeSend: function () {
            $modal.addClass('active');
        },
        error: function (jqXHR, statusText, error) {
            $body.html(jqXHR.responseText)
        },
        success: function (result) {
            if (callback) {
                callback($body, result, $modal)
            } else {
                $body.html(result)
            }
        }
    });
}

App.submit = function (target) {
    $(document).on('click', target, function (e) {
        const $this = $(this)
        if (!$this.hasClass('loading')) {
            let $form = $this.parents('form')
            $.ajax({
                type: 'GET',
                url: $form.attr('action'),
                data: $form.serialize(),
                dataType: 'json',
                context: $this,
                beforeSend: function () {
                    $this.addClass('loading')
                },
                error: function (jqXHR, statusText, error) {
                    console.log(`${statusText} ${error}`)
                    App.tip(error)
                    $this.removeClass('loading')
                },
                success: function (result) {
                    console.log(result)
                    window.location.reload();
                }
            });
        }
    })
}

App.rclone = function ($this, $files_a) {
    console.log($files_a)
    App.modal($this, '', 'md', function ($body, html, $modal) {
        $body.html(`<div class="modal-preview modal-preview-code text-break"><pre>${html}</pre></div>`)
    })
}

App.create_folder = function ($this, $files_a) {
    // const name = $files_a ? $files_a.attr('title') : $this.attr('title')
    console.log($files_a)
    const f = `<input class="form-input" type="text" name="folder_name" placeholder="文件夹名称">`
    App._modal_submit($this, f)
}

App.rename = function ($this, $files_a) {
    const name = $files_a.attr('title')
    const f = `<input class="form-input" type="text" name="new_name" placeholder="${name}">`
    App._modal_submit($this, f)
}

App.move = function ($this, $files_a) {
    const name = $files_a.attr('title')
    const f = `<label class="form-label mb-2">移动<span class="text-bold text-error px-2">${name}</span>到</label><input class="form-input" type="text" name="parent" placeholder="${window.request_path}">`
    App._modal_submit($this, f)
}

App.delete = function ($this, $files_a) {
    const name = $files_a.attr('title')
    const f = `<label class="form-label mb-2">确认删除<span class="text-bold text-large text-error px-2">${name}</span>?</label>`
    App._modal_submit($this, f)
}

App._modal_submit = function ($this, form_html) {
    const url = $this.attr('href') || $this.data('href')
    const $html = `<form action="${url}">
    <div class="form-group">
        ${form_html}
    </div>
    <div class="form-group">
        <button type="button" class="btn btn-md btn-block btn-danger btn-submit">提交</button>
    </div></form>`;
    App.modal($this, $html)
    App.submit('.btn-submit')
}

$(function () {
    $(document).on('click', '#files a.files-a-loaded', function (e) {
        e.preventDefault();
        let gallery = [];
        const type = $(this).data('type');
        if (type === 'image') {
            $('#files a.files-a-loaded').each(function () {
                const $this = $(this);
                const img = $this.find('img')
                gallery.push({
                    src: $this.data('download'),
                    type: $this.data('type'),
                    thumb: img.data('src') || img.attr('src')
                })
            })
        } else {
            const img = $(this).find('img')
            gallery.push({
                src: $(this).data('download'),
                type: $(this).data('type'),
                caption: $(this).attr('title'),
                thumb: img.data('src') || img.attr('src')
            })
        }
        Fancybox.show(gallery);
        return false;
    });
    $(document).on('click', '#files .files-a .context', function (e) {
        e.preventDefault();
        $('.context.active').removeClass('active')
        $(window).off('scroll click')

        const menu = $('.files-menu')
        const $this = $(this)
        const $parent = $this.parent('.files-a')
        // const $name = $parent.find('.name').attr('title')
        // const $is_folder = $parent.hasClass('files-folder')
        const h = $this.innerHeight()
        const hide = () => {
            menu.css({'display': 'none', 'left': 0, 'top': 0})
            $('.context.active').removeClass('active')
        }
        menu.data('ref-id', $parent.attr('id'))

        if ($this.hasClass('active')) {
            hide()
        } else {
            $this.addClass('active').focus()
            menu.css({
                'display': 'block',
                'left': $this.offset().left - 90,
                'top': $this.offset().top + h + 10 - $(window).scrollTop()
            })
            $(window).one('scroll click', function (e) {
                hide()
            })
        }
        return false;
    });
    $(document).on('click', '#files .files-file', function (e) {
        e.preventDefault();
        const $this = $(this);
        const download = $this.data('download')
        const fileExt = $this.attr('href').split('/').pop().split('.').pop()
        const fileExtList = ['md', 'js', 'json', 'txt', 'php', 'conf', 'html', 'css', 'xml', 'py', 'java', 'sql', 'ts', 'jsx']
        if (fileExtList.includes(fileExt)) {
            App.modal($this, '', 'md', function ($body, html, $modal) {
                $modal.find('.buttons').html(`<a href="${download}" class="btn tooltip" data-tooltip="下载"><svg viewBox="0 0 24 24" class="svg-icon svg-tray_arrow_down"><path class="svg-path-tray_arrow_down" d="M2 12H4V17H20V12H22V17C22 18.11 21.11 19 20 19H4C2.9 19 2 18.11 2 17V12M12 15L17.55 9.54L16.13 8.13L13 11.25V2H11V11.25L7.88 8.13L6.46 9.55L12 15Z"></path></svg></a>`)
                $body.html(`<div class="modal-preview modal-preview-code text-break"><pre>${html}</pre></div>`)
            })
        } else {
            let a = document.createElement('a');
            a.href = download;
            a.click();
        }
        return false;
    });
    $(document).on('click', '.modal-action', function (e) {
        const $this = $(this)
        const $action = $this.data('action')
        let url = `${window.page_url}?a=${$action}`
        let $files_a = null;
        if ($this.hasClass('files-menu-item')) {
            const $parent = $this.parent('.files-menu')
            $files_a = $(`#${$parent.data('ref-id')}`)
            if ($files_a.hasClass('files-folder')) {
                url = `${$files_a.attr('href')}?a=${$action}`
            }
        }
        $this.data('href', url)
        App[$action]($this, $files_a)
    });
    ["#files"].forEach((function (t) {
            yall({
                observeChanges: !0,
                observeRootSelector: t,
                lazyClass: "files-lazy",
                threshold: 300,
                events: {
                    load: function (t) {
                        let i = t.target;
                        i.classList.remove("files-img-placeholder");
                        i.parentElement.classList.add("files-a-loaded")
                    }
                }
            })
        }
    ));

    $(document).on('click', '.upload', function () {
        App.tip('功能未开放')
        return false;
    });

    $(document).on('click', '.btn-layout .btn', function () {
        let $this = $(this);
        let value = $this.val();
        console.log(value)
        if ($this.hasClass('modal-action') || !value) {
            return false;
        }

        $this.addClass('active').siblings().removeClass('active')
        $('#files').attr('class', `${value}`);

        document.cookie = `pyListLayout=${value}; path=/`;
    });

    window.load_url = {};
    $(window).scroll(function () {
        let scrollTop = $(window).scrollTop();
        let scrollHeight = $(document).height();
        let windowHeight = $(window).height();
        if (scrollTop + windowHeight >= scrollHeight - 50) {
            let file_list = $('#files')
            let page_url = file_list.data('page')
            if (page_url && !window.load_url[page_url]) {
                window.load_url[page_url] = page_url
                $('.loading').removeClass('d-none')
                $.getJSON(window.page_url, {'page': page_url}, function (data) {
                    file_list.append(data['html'])
                    file_list.data('page', data['page'])
                    $('.loading').addClass('d-none')
                });
            }
        }
    });
});
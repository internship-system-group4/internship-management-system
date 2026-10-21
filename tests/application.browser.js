async page => {
  const base = 'http://localhost:57982';
  const firebase = 'http://localhost:4900/firebase';
  let checks = 0;
  function check(ok, message) { if (!ok) throw Error(message); checks++; }
  async function reset() { await page.request.post(firebase + '/__reset'); }
  async function read(path) { return (await page.request.get(firebase + '/' + path + '.json')).json(); }
  async function write(path, data) { await page.request.put(firebase + '/' + path + '.json', {data}); }
  async function form() { await page.goto(base + '/__fixture.aspx'); }
  async function errorIncludes(text) { check((await page.getByRole('alert').innerText()).includes(text), text); }
  async function submit(letter, cv, confirm) {
    await page.getByRole('textbox',{name:'Cover letter (required)'}).fill(letter);
    await page.getByRole('textbox',{name:'CV link (required)'}).fill(cv);
    if (confirm) await page.getByRole('checkbox').check();
    await page.getByRole('button',{name:'Submit application'}).click();
  }
  const letter = 'I enjoy building accessible web applications with C# and HTML and would love to develop my skills through this internship.';
  await reset();
  await page.context().clearCookies();
  await page.goto(base + '/Pages/Student/Apply.aspx?opportunityId=internship-one');
  check(page.url().includes('/Account/Login.aspx'), 'Anonymous redirected');
  await form();
  check((await page.getByRole('heading',{name:'Software Development Intern'}).count()) === 1, 'Opportunity loaded');
  check((await page.getByRole('textbox',{name:'CV link (required)'}).inputValue()).startsWith('https:'), 'Profile CV prefilled');
  await submit('Too short', 'https://example.com/cv.pdf', true); await errorIncludes('between 50');
  await submit(letter, 'http://example.com/cv.pdf', true); await errorIncludes('HTTPS');
  await page.getByRole('checkbox').uncheck();
  await submit(letter, 'https://example.com/cv.pdf', false); await errorIncludes('Confirm');
  await page.goto(base + '/Pages/Student/Apply.aspx'); await errorIncludes('Choose an internship');
  await page.goto(base + '/Pages/Student/Apply.aspx?id=bad/key'); await errorIncludes('Choose an internship');
  await page.goto(base + '/Pages/Student/Apply.aspx?id=missing'); await errorIncludes('could not be found');
  await form();
  const opportunity = await read('opportunities/internship-one');
  await write('opportunities/internship-one', {...opportunity, Status:2});
  await submit(letter, 'https://example.com/cv.pdf', true); await errorIncludes('no longer accepting');
  await reset();
  for (const patch of [{FilledSeats:4},{ApplicationDeadline:1}]) {
    await write('opportunities/internship-one', {...opportunity,...patch}); await form(); await errorIncludes('no longer accepting');
  }
  await write('opportunities/internship-one', {...opportunity,EligibleMajors:['Architecture']}); await form(); await errorIncludes('college or major');
  await reset(); await write('placements/student-one',{Id:'student-one',StudentId:'student-one'}); await form(); await errorIncludes('confirmed internship');
  await reset(); await form();
  await page.request.post(firebase+'/__fail-writes');
  await submit(letter, 'https://example.com/cv.pdf', true); await errorIncludes('could not confirm');
  check((await page.getByRole('textbox',{name:'Cover letter (required)'}).inputValue())===letter,'Write failure retains form');
  check(Object.keys(await read('applications')).length===0,'Failed write creates no application');
  await reset(); await form();
  for (const width of [1440,768,390]) {
    await page.setViewportSize({width,height:1000});
    check(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'No overflow at '+width);
    await page.screenshot({path: 'tests/artifacts/application-'+width+'.png',fullPage:true});
  }
  await page.setViewportSize({width:1440,height:1000});
  await submit(letter, 'https://example.com/cv.pdf', true);
  await page.waitForURL('**/MyApplications.aspx');
  check((await page.getByRole('status').innerText()).includes('submitted'), 'Success message');
  check((await page.locator('.application-row').innerText()).includes('Pending'), 'Student sees Pending');
  const saved=Object.values(await read('applications'));
  check(saved.length===1 && saved[0].Status===0 && saved[0].StudentId==='student-one' && saved[0].CompanyId==='company-one' && saved[0].CoverLetter===letter && saved[0].SubmittedAt>0, 'Stored contract');
  await form(); await errorIncludes('already applied');
  check(Object.keys(await read('applications')).length===1,'Duplicate prevented');
  const conflict=await page.request.put(firebase+'/applications/'+saved[0].Id+'.json',{headers:{'if-match':'null_etag'},data:{Status:2}});
  check(conflict.status()===412,'Conditional write rejects overwrite');
  check((await read('applications/'+saved[0].Id)).Status===0,'Existing application preserved');
  await page.goto(base+'/__fixture.aspx?user=supervisor-one');
  check((await page.locator('.application-row').innerText()).includes('Osama Banihani'),'Company sees student');
  check((await page.locator('.application-row').innerText()).includes('Pending'),'Company sees Pending');
  await page.goto(base+'/Pages/Student/Apply.aspx?id=internship-one');
  check(page.url().includes('AccessDenied'),'Wrong role denied');
  await page.goto(base+'/__fixture.aspx?user=other-supervisor');
  check(await page.locator('.application-row').count()===0,'Other company isolated');
  await reset();
  await write('applications/legacy-push-key',{...saved[0],Id:'legacy-push-key'});
  await form(); await errorIncludes('already applied');
  await reset(); await form();
  return { passed: checks, system: 'Web Forms + local Firebase REST simulation' };
}
